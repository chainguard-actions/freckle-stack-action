<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.19

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.19** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple workflow files reference GitHub Actions using mutable version tags instead of full 40-character SHA commit hashes, making them vulnerable to supply-chain attacks if the tag is moved.

ci.yml: actions/checkout@v6, actions/setup-node@v6
example.yml: actions/checkout@v6, actions/setup-node@v6, actions/upload-artifact@v7, actions/download-artifact@v8
mergeabot.yml: freckle/mergeabot-action@v2
release.yml: actions/checkout@v6, actions/create-github-app-token@v3, cycjimmy/semantic-release-action@v6.0.0

Locations:

- `.github/workflows/ci.yml:9`
- `.github/workflows/ci.yml:10`
- `.github/workflows/example.yml:24`
- `.github/workflows/example.yml:25`
- `.github/workflows/example.yml:30`
- `.github/workflows/example.yml:57`
- `.github/workflows/example.yml:58`
- `.github/workflows/mergeabot.yml:14`
- `.github/workflows/release.yml:9`
- `.github/workflows/release.yml:13`
- `.github/workflows/release.yml:18`

### permissions (severity: medium)

missing-permissions: These workflow files have no top-level `permissions:` key and no job-level `permissions:` key on any job. Without explicit permissions, the GITHUB_TOKEN is granted default (potentially broad) permissions.

Locations:

- `.github/workflows/ci.yml:1`
- `.github/workflows/example.yml:1`
- `.github/workflows/release.yml:1`

### script-injection (severity: high)

Sub-rule (a): GitHub Actions expressions (${{ ... }}) are interpolated directly inside `run:` shell command strings, allowing injection of shell metacharacters before the shell ever sees the value.

1. generate-matrix/action.yml: `find ${{ inputs.find-options }} -printf ...` — the entire `find` argument list comes from an attacker-controllable input with no quoting or sanitization.

2. example.yml ("Check compiler[-*] outputs" step): `[[ "${{ steps.stack.outputs.compiler }}" = ghc-${{ matrix.stack.ghc }} ]]` and `[[ "${{ steps.stack.outputs.compiler-version }}" = ${{ matrix.stack.ghc }} ]]` — step outputs and matrix values interpolated directly into shell.

3. example.yml ("Check presence of other outputs" step): Numerous `[[ -n "${{ steps.stack.outputs.* }}" ]]` lines interpolate step outputs directly into shell.

4. example.yml (test-stack-yamls run step): `if [[ -L '${{ matrix.stack-yaml }}' ]]` — matrix value interpolated directly into shell inside single quotes (which do not prevent injection at the YAML-template level).

Locations:

- `generate-matrix/action.yml:18`
- `.github/workflows/example.yml:69`
- `.github/workflows/example.yml:70`
- `.github/workflows/example.yml:71`
- `.github/workflows/example.yml:75`
- `.github/workflows/example.yml:113`

### github-env-injection (severity: high)

In generate-matrix/action.yml, the `inputs.find-options` value (an attacker-controllable input) is interpolated directly into the `find` command inside the `run:` block, and the output of that command is written to `$GITHUB_OUTPUT` via a heredoc without any newline sanitization (`printf '%s' ... | tr -d '\n\r'`). An attacker-controlled `find-options` value could inject newlines into the heredoc, poisoning subsequent entries in `$GITHUB_OUTPUT`.

Offending lines:
  find ${{ inputs.find-options }} -printf "%f"\n | sort -V | jq --slurp
  } >> "$GITHUB_OUTPUT"

Locations:

- `generate-matrix/action.yml:18`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, permissions, script-injection, github-env-injection

**Notes:**

Fixed all findings across 5 files:

1. ci.yml: Pinned actions/checkout@v6 and actions/setup-node@v6 to full SHAs; added `permissions: contents: read`.

2. example.yml: Pinned all 5 action references (checkout, setup-node, upload-artifact, download-artifact x3) to full SHAs; added `permissions: contents: read`; fixed script injection in 'Check compiler[-*] outputs' step (moved compiler/ghc expressions to env block), 'Check presence of other outputs' step (moved all 20 step output expressions to env block), and test-stack-yamls run step (moved matrix.stack-yaml to STACK_YAML env var, changed single quotes to double quotes).

3. mergeabot.yml: Pinned freckle/mergeabot-action@v2 to full SHA. Already had permissions block.

4. release.yml: Pinned actions/checkout@v6, actions/create-github-app-token@v3, and cycjimmy/semantic-release-action@v6.0.0 to full SHAs; added `permissions: contents: write` (needed for semantic-release to create releases/tags).

5. generate-matrix/action.yml: Moved `${{ inputs.find-options }}` into env block as FIND_OPTIONS to fix script injection; piped jq output through `tr -d '\n\r'` before writing to GITHUB_OUTPUT to prevent newline injection attacks.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed two script injection vulnerabilities: (1) In generate-matrix/action.yml, replaced unquoted `find $FIND_OPTIONS` with a safe bash array expansion using `read -ra find_opts <<< "$FIND_OPTIONS"` and `find "${find_opts[@]}"`, removing the shellcheck suppression comment that acknowledged the unsafe expansion. (2) In .github/workflows/example.yml, added double quotes around `$EXPECTED_GHC` in both bash `[[` comparisons to prevent word splitting and glob expansion from the matrix-derived value.

