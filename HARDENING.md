<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.16

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.16** was hardened automatically. 5 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

The composite action's run: block directly interpolates ${{ inputs.find-options }} and ${{ inputs.working-directory }} into shell commands. An attacker-controlled caller can supply values containing shell metacharacters (e.g. semicolons, pipes, backticks) that will be executed by the shell before any quoting can protect them. Specifically: `find ${{ inputs.find-options }} -printf ...` and the `working-directory: ${{ inputs.working-directory }}` field both embed raw expression values into shell context. Rule (a) violated.

Locations:

- `generate-matrix/action.yml:20`
- `generate-matrix/action.yml:23`

### github-env-injection (severity: high)

The composite action writes the output of `find ${{ inputs.find-options }} ...` directly to $GITHUB_OUTPUT without sanitization (no `printf '%s' ... | tr -d '\n\r'` step). The `inputs.find-options` value is caller-controlled and could contain newlines that inject additional key=value pairs into GITHUB_OUTPUT, enabling environment injection. The heredoc delimiter pattern (<<EOM) does not protect against embedded newlines in the find output itself.

Locations:

- `generate-matrix/action.yml:21`

### script-injection (severity: high)

Multiple run: blocks in example.yml directly interpolate ${{ ... }} expressions into shell commands, violating rule (a):
- 'Check compiler[-*] outputs' step: `[[ "${{ steps.stack.outputs.compiler }}" = ghc-${{ matrix.stack.ghc }} ]]` and `[[ "${{ steps.stack.outputs.compiler-version }}" = ${{ matrix.stack.ghc }} ]]`
- 'Check presence of other outputs' step: multiple `[[ -n "${{ steps.stack.outputs.* }}" ]]` lines
- 'test-stack-yamls' job: `if [[ -L '${{ matrix.stack-yaml }}' ]]; then` — matrix.stack-yaml is derived from find output and could contain shell metacharacters

Locations:

- `.github/workflows/example.yml:75`
- `.github/workflows/example.yml:76`
- `.github/workflows/example.yml:82`
- `.github/workflows/example.yml:130`

### unpinned-uses (severity: high)

All workflow files reference external actions using mutable version tags instead of full 40-character SHA commit digests, making them vulnerable to supply-chain attacks if the tag is moved:
- ci.yml: actions/checkout@v6, actions/setup-node@v6
- example.yml: actions/checkout@v6, actions/setup-node@v6, actions/upload-artifact@v7, actions/download-artifact@v8
- release.yml: actions/checkout@v6, actions/create-github-app-token@v3, cycjimmy/semantic-release-action@v4

Locations:

- `.github/workflows/ci.yml:8`
- `.github/workflows/ci.yml:9`
- `.github/workflows/example.yml:22`
- `.github/workflows/example.yml:23`
- `.github/workflows/example.yml:27`
- `.github/workflows/example.yml:40`
- `.github/workflows/example.yml:55`
- `.github/workflows/example.yml:100`
- `.github/workflows/release.yml:12`
- `.github/workflows/release.yml:16`
- `.github/workflows/release.yml:21`

### missing-permissions (severity: medium)

None of the three workflow files define a top-level `permissions:` key, and no individual job within them defines job-level `permissions:` blocks. Without explicit permissions, workflows run with the default repository permissions (which may include write access to contents, packages, etc.), violating the principle of least privilege. Affected files: ci.yml, example.yml, release.yml.

Locations:

- `.github/workflows/ci.yml:1`
- `.github/workflows/example.yml:1`
- `.github/workflows/release.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all 5 findings across 4 files:

1. generate-matrix/action.yml: Moved inputs.find-options to env var FIND_OPTIONS to prevent shell injection; replaced heredoc GITHUB_OUTPUT write with sanitized single-line echo using tr -d '\n\r' to prevent newline injection.

2. .github/workflows/example.yml: Moved all ${{ steps.stack.outputs.* }}, ${{ matrix.stack.ghc }}, and ${{ matrix.stack-yaml }} expressions from run: blocks to env: blocks; pinned all 5 action references to full SHAs; added top-level permissions: contents: read and per-job permissions blocks.

3. .github/workflows/ci.yml: Pinned actions/checkout@v6 and actions/setup-node@v6 to full SHAs; added top-level and job-level permissions: contents: read.

4. .github/workflows/release.yml: Pinned actions/checkout@v6, actions/create-github-app-token@v3, and cycjimmy/semantic-release-action@v4 to full SHAs; added top-level permissions: contents: read and job-level permissions: contents: write, id-token: write (needed for release creation and app token generation).

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in hardened/action/generate-matrix/action.yml at line 23. Replaced unquoted `find $FIND_OPTIONS` with a bash array approach: added `read -ra opts <<< "$FIND_OPTIONS"` to safely split the options on whitespace, then changed the find command to `find "${opts[@]}"`. This preserves the intentional word-splitting behavior (allowing multiple find arguments like `-type f -maxdepth 1 -name 'stack*.yaml'`) while preventing shell metacharacter injection, since each array element is properly quoted when expanded.

### Iteration 3

**Fixes applied:** script-injection

**Notes:**

Fixed unquoted $EXPECTED_GHC variable in the 'Check compiler[-*] outputs' step in .github/workflows/example.yml. Changed `ghc-$EXPECTED_GHC` to `"ghc-$EXPECTED_GHC"` and `$EXPECTED_GHC` to `"$EXPECTED_GHC"` in the bash [[ ]] comparisons to prevent glob/pattern expansion of the workflow-controllable matrix value.

