<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.27

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.27** was hardened automatically. 5 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): `${{ inputs.find-options }}` is directly interpolated inside a `run:` shell command in the composite action. An attacker-controlled calling workflow can supply a value containing shell metacharacters (`;`, `|`, `$(...)`, etc.) to execute arbitrary commands. The offending line is: `find ${{ inputs.find-options }} -printf "%f"\n' | sort -V | jq --slurp`

Locations:

- `generate-matrix/action.yml:21`

### script-injection (severity: high)

Rule (a): Multiple `${{ ... }}` expressions are directly interpolated inside `run:` shell command strings in example.yml. Affected expressions include `${{ steps.stack.outputs.compiler }}`, `${{ steps.stack.outputs.compiler-version }}`, `${{ matrix.stack.ghc }}` (in the 'Check compiler[-*] outputs' step), all `${{ steps.stack.outputs.* }}` expansions in the 'Check presence of other outputs' step, and `${{ matrix.stack-yaml }}` in the test-stack-yamls job. These values flow through YAML template substitution before the shell sees them, enabling injection of shell metacharacters.

Locations:

- `.github/workflows/example.yml:57`
- `.github/workflows/example.yml:58`
- `.github/workflows/example.yml:62`
- `.github/workflows/example.yml:107`
- `.github/workflows/example.yml:122`

### github-env-injection (severity: high)

The composite action's `run:` block writes a value derived from `inputs.find-options` (an untrusted caller-controlled input) directly to `$GITHUB_OUTPUT` via `find ${{ inputs.find-options }} ... >> "$GITHUB_OUTPUT"`. The input is interpolated without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`), allowing a newline-injection attack that can poison GITHUB_OUTPUT with arbitrary key-value pairs.

Locations:

- `generate-matrix/action.yml:21`

### unpinned-uses (severity: high)

All `uses:` references in the workflow files use mutable tags instead of immutable 40-character SHA commit hashes, making them vulnerable to supply-chain attacks if the referenced tag is moved or the upstream repository is compromised. Failing references include: `actions/checkout@v7`, `actions/setup-node@v7`, `actions/upload-artifact@v7`, `actions/download-artifact@v8` (ci.yml and example.yml); `freckle/mergeabot-action@v3` (mergeabot.yml); `actions/checkout@v7`, `actions/create-github-app-token@v3`, `cycjimmy/semantic-release-action@v6.0.0` (release.yml).

Locations:

- `.github/workflows/ci.yml:9`
- `.github/workflows/ci.yml:10`
- `.github/workflows/example.yml:18`
- `.github/workflows/example.yml:19`
- `.github/workflows/example.yml:24`
- `.github/workflows/example.yml:40`
- `.github/workflows/example.yml:41`
- `.github/workflows/example.yml:79`
- `.github/workflows/example.yml:100`
- `.github/workflows/example.yml:101`
- `.github/workflows/example.yml:113`
- `.github/workflows/example.yml:118`
- `.github/workflows/mergeabot.yml:14`
- `.github/workflows/release.yml:12`
- `.github/workflows/release.yml:17`
- `.github/workflows/release.yml:24`

### missing-permissions (severity: medium)

The workflow files `ci.yml`, `example.yml`, and `release.yml` have no top-level `permissions:` block and no per-job `permissions:` blocks. Without explicit permissions, the GITHUB_TOKEN is granted default (potentially write) permissions, violating the principle of least privilege. Only `mergeabot.yml` has a top-level `permissions:` block.

Locations:

- `.github/workflows/ci.yml:1`
- `.github/workflows/example.yml:1`
- `.github/workflows/release.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all 5 findings across 5 files:

1. generate-matrix/action.yml: Moved inputs.find-options to env var FIND_OPTIONS, used xargs-based tokenization into a bash array to safely pass arguments to find, eliminating both script-injection and github-env-injection.

2. example.yml: Moved all ${{ steps.stack.outputs.* }}, ${{ matrix.stack.ghc }}, and ${{ matrix.stack-yaml }} expressions from run: shell strings into env: blocks. Added permissions: contents: read. Pinned all 4 action references to full SHAs.

3. ci.yml: Added permissions: contents: read. Pinned actions/checkout@v7 and actions/setup-node@v7 to full SHAs.

4. mergeabot.yml: Pinned freckle/mergeabot-action@v3 to full SHA (already had permissions block).

5. release.yml: Added permissions: contents: write, pull-requests: write. Pinned actions/checkout@v7, actions/create-github-app-token@v3, and cycjimmy/semantic-release-action@v6.0.0 to full SHAs.

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed unquoted variable expansions in the 'Check compiler[-*] outputs' step of .github/workflows/example.yml. Changed `[[ "$COMPILER" = ghc-$EXPECTED_GHC ]]` to `[[ "$COMPILER" = "ghc-$EXPECTED_GHC" ]]` and `[[ "$COMPILER_VERSION" = $EXPECTED_GHC ]]` to `[[ "$COMPILER_VERSION" = "$EXPECTED_GHC" ]]`. Both `$EXPECTED_GHC` expansions are now double-quoted, preventing shell metacharacter interpretation and potential command injection.

