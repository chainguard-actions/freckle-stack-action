<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.26

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.26** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Direct expression interpolation (${{ }}) inside run: shell commands. (a) In generate-matrix/action.yml, `${{ inputs.find-options }}` is interpolated directly into a `find` shell command — an attacker-controlled input can inject arbitrary shell commands. (b) In example.yml, `${{ steps.stack.outputs.compiler }}`, `${{ steps.stack.outputs.compiler-version }}`, `${{ matrix.stack.ghc }}`, and `${{ matrix.stack-yaml }}` are all interpolated directly inside run: blocks — these values flow through YAML template substitution before the shell sees them, enabling script injection.

Locations:

- `generate-matrix/action.yml:22`
- `.github/workflows/example.yml:56`
- `.github/workflows/example.yml:62`
- `.github/workflows/example.yml:113`

### github-env-injection (severity: high)

In generate-matrix/action.yml, the untrusted input `${{ inputs.find-options }}` is interpolated directly into the run: shell command that writes to $GITHUB_OUTPUT via a heredoc block (`} >> "$GITHUB_OUTPUT"`). The value is not sanitized with `printf '%s' ... | tr -d '\n\r'` before the write, allowing newline injection into the output file which can poison subsequent steps' environment.

Locations:

- `generate-matrix/action.yml:20`

### unpinned-uses (severity: high)

All uses: references in workflow files use mutable tags instead of immutable 40-character SHA digests, making the workflows vulnerable to supply-chain attacks if any referenced action is compromised or its tag is moved. Failing references: actions/checkout@v7, actions/setup-node@v7, actions/upload-artifact@v7, actions/download-artifact@v8, freckle/mergeabot-action@v2, actions/create-github-app-token@v3, cycjimmy/semantic-release-action@v6.0.0.

Locations:

- `.github/workflows/ci.yml:9`
- `.github/workflows/ci.yml:10`
- `.github/workflows/example.yml:18`
- `.github/workflows/example.yml:19`
- `.github/workflows/example.yml:24`
- `.github/workflows/example.yml:46`
- `.github/workflows/example.yml:47`
- `.github/workflows/example.yml:97`
- `.github/workflows/example.yml:109`
- `.github/workflows/example.yml:110`
- `.github/workflows/mergeabot.yml:13`
- `.github/workflows/release.yml:13`
- `.github/workflows/release.yml:17`
- `.github/workflows/release.yml:23`

### missing-permissions (severity: medium)

The workflow files ci.yml, example.yml, and release.yml have no top-level `permissions:` block and no job-level `permissions:` blocks on any of their jobs. Without explicit permissions, workflows run with the default (potentially broad) token permissions, violating the principle of least privilege.

Locations:

- `.github/workflows/ci.yml:1`
- `.github/workflows/example.yml:1`
- `.github/workflows/release.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all four findings:

1. script-injection: In generate-matrix/action.yml, moved `inputs.find-options` to an env var (FIND_OPTIONS) and used xargs-based array tokenization to safely pass it to `find`. In example.yml, moved all ${{ steps.stack.outputs.* }}, ${{ matrix.stack.ghc }}, and ${{ matrix.stack-yaml }} expressions from run: blocks into step env: blocks, referencing them as plain shell variables.

2. github-env-injection: The find-options input is now in an env var and tokenized via xargs before use in the heredoc that writes to $GITHUB_OUTPUT, preventing newline injection.

3. unpinned-uses: Pinned all 7 unique action references to full 40-char commit SHAs across ci.yml, example.yml, mergeabot.yml, and release.yml.

4. missing-permissions: Added `permissions: contents: read` to ci.yml and example.yml; added `permissions: contents: write` to release.yml (required for semantic-release to push tags). mergeabot.yml already had explicit permissions.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed two unquoted variable expansions in the 'Check compiler[-*] outputs' step in .github/workflows/example.yml. Changed `[[ "$COMPILER" = ghc-$EXPECTED_GHC ]]` to `[[ "$COMPILER" = "ghc-$EXPECTED_GHC" ]]` and `[[ "$COMPILER_VERSION" = $EXPECTED_GHC ]]` to `[[ "$COMPILER_VERSION" = "$EXPECTED_GHC" ]]`. Quoting the right-hand side of bash [[ comparisons prevents glob characters in the workflow-controllable matrix.stack.ghc value from being interpreted as patterns.

