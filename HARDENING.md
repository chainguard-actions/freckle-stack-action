<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.29

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.29** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) violation: The `run:` block in generate-matrix/action.yml directly interpolates the expression `${{ inputs.find-options }}` inside a shell command string. An attacker who controls the calling workflow can supply a malicious value for `inputs.find-options` containing shell metacharacters (e.g. `;`, `|`, `$(...)`) that will be executed by the shell. Offending line: `find ${{ inputs.find-options }} -printf "%f"\n' | sort -V | jq --slurp`

Locations:

- `generate-matrix/action.yml:25`

### github-env-injection (severity: high)

The `run:` block writes output derived from the untrusted input `${{ inputs.find-options }}` directly to `$GITHUB_OUTPUT` without applying the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). A newline injected via `inputs.find-options` could allow an attacker to inject arbitrary key-value pairs into GITHUB_OUTPUT, potentially overwriting outputs consumed by downstream steps. The write occurs at the closing `} >>"$GITHUB_OUTPUT"` line.

Locations:

- `generate-matrix/action.yml:27`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed generate-matrix/action.yml: (1) Moved `${{ inputs.find-options }}` to the `env:` block as `FIND_OPTIONS` and used the xargs/while-read pattern to tokenize it into a bash array, preventing shell metacharacter injection. (2) Captured jq output into a variable and sanitized it with `tr -d '\n\r'` before writing to $GITHUB_OUTPUT, preventing newline injection. Replaced the heredoc output format with a single-line `printf` write since the value is now sanitized to be newline-free.

