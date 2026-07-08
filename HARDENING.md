<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.23

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **freckle--stack-action/v5.7.23** was hardened automatically. 5 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): The run: block in generate-matrix/action.yml directly interpolates ${{ inputs.find-options }} into a shell command (`find ${{ inputs.find-options }} -printf ...`). An attacker-controlled value for this input can inject arbitrary shell commands.

Locations:

- `generate-matrix/action.yml:25`

### github-env-injection (severity: high)

The run: block in generate-matrix/action.yml writes the output of `find ${{ inputs.find-options }} ...` directly to $GITHUB_OUTPUT without sanitization (no `printf '%s' ... | tr -d '\n\r'` step). The inputs.find-options value is attacker-controlled and could inject additional environment variable assignments via newlines.

Locations:

- `generate-matrix/action.yml:25`

### script-injection (severity: high)

Rule (a): Multiple run: blocks in example.yml directly interpolate ${{ }} expressions into shell commands. (1) Line 68-69: `${{ steps.stack.outputs.compiler }}` and `${{ matrix.stack.ghc }}` are interpolated in a bash comparison. (2) Lines 74-97: Multiple `${{ steps.stack.outputs.* }}` expressions are interpolated in bash test commands. (3) Line 119: `${{ matrix.stack-yaml }}` is interpolated in a bash conditional. All of these bypass shell quoting and allow injection of shell metacharacters.

Locations:

- `.github/workflows/example.yml:68`
- `.github/workflows/example.yml:74`
- `.github/workflows/example.yml:119`

### unpinned-uses (severity: high)

Multiple workflow files use action references pinned to mutable tags or version strings instead of full 40-character commit SHAs. Failing references: ci.yml: actions/checkout@v7, actions/setup-node@v6. example.yml: actions/checkout@v7, actions/setup-node@v6, actions/upload-artifact@v7, actions/download-artifact@v8. mergeabot.yml: freckle/mergeabot-action@v2. release.yml: actions/checkout@v7, actions/create-github-app-token@v3, cycjimmy/semantic-release-action@v6.0.0.

Locations:

- `.github/workflows/ci.yml:9`
- `.github/workflows/example.yml:23`
- `.github/workflows/mergeabot.yml:13`
- `.github/workflows/release.yml:11`

### missing-permissions (severity: medium)

The following workflow files have no top-level permissions: key and no job-level permissions: blocks, meaning they run with the default (potentially broad) token permissions: ci.yml, example.yml, release.yml.

Locations:

- `.github/workflows/ci.yml:1`
- `.github/workflows/example.yml:1`
- `.github/workflows/release.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all findings: (1) generate-matrix/action.yml: moved inputs.find-options to FIND_OPTIONS env var to prevent script injection, and sanitized output with tr -d '\n\r' before writing to GITHUB_OUTPUT to prevent env injection. (2) example.yml: moved all ${{ steps.stack.outputs.* }}, ${{ matrix.stack.ghc }}, and ${{ matrix.stack-yaml }} expressions into env: blocks and referenced them as plain env vars in run: scripts. Also pinned all action references to full SHAs and added top-level permissions: contents: read. (3) ci.yml: pinned actions/checkout@v7 and actions/setup-node@v6 to full SHAs, added permissions: contents: read. (4) mergeabot.yml: pinned freckle/mergeabot-action@v2 to full SHA. (5) release.yml: pinned actions/checkout@v7, actions/create-github-app-token@v3, and cycjimmy/semantic-release-action@v6.0.0 to full SHAs, added permissions: contents: write.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed two script injection vulnerabilities:
1. hardened/action/generate-matrix/action.yml line 26: Replaced unquoted `find $FIND_OPTIONS` with `read -ra OPTS <<< "$FIND_OPTIONS"` + `find "${OPTS[@]}"` to safely split and expand the options as an array, preventing shell metacharacter injection.
2. hardened/action/.github/workflows/example.yml lines 86-87: Quoted `$EXPECTED_GHC` in both `[[ ]]` comparisons (`ghc-$EXPECTED_GHC` → `"ghc-$EXPECTED_GHC"` and `$EXPECTED_GHC` → `"$EXPECTED_GHC"`) to prevent glob pattern matching exploitation.

