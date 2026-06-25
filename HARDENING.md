<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.16

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **freckle--stack-action/v5.7.16** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The `run:` block in generate-matrix/action.yml directly interpolates `${{ inputs.find-options }}` into the shell command string (`find ${{ inputs.find-options }} -printf "%f"\n | sort -V | jq --slurp`). Any caller can supply shell metacharacters (`;`, `|`, `$(...)`, backticks, etc.) via this input to achieve arbitrary command execution on the runner.

Locations:

- `generate-matrix/action.yml:25`

### github-env-injection (severity: high)

The `run:` block in generate-matrix/action.yml writes output derived from the unsanitized `${{ inputs.find-options }}` expression directly to `$GITHUB_OUTPUT` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker-controlled value containing embedded newlines could inject arbitrary key=value pairs into GITHUB_OUTPUT, potentially hijacking outputs consumed by downstream steps.

Locations:

- `generate-matrix/action.yml:25`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed generate-matrix/action.yml: (1) Moved `${{ inputs.find-options }}` from the shell run block into an `env:` block as `FIND_OPTIONS` to prevent template/script injection. The shell script uses `read -ra find_args <<< "$FIND_OPTIONS"` to safely word-split the arguments and passes them as `"${find_args[@]}"` to find. (2) Captured the find/sort/jq output in a variable and wrote it to GITHUB_OUTPUT using `printf '%s' "$stack_yamls" | tr -d '\r'` to strip carriage returns and prevent newline injection into GITHUB_OUTPUT.

