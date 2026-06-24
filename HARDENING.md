<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.21

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **freckle--stack-action/v5.7.21** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The `run:` block in generate-matrix/action.yml directly interpolates `${{ inputs.find-options }}` into a shell command. An attacker-controlled value for this input can inject arbitrary shell commands. Offending line: `find ${{ inputs.find-options }} -printf "%f"\n' | sort -V | jq --slurp`

Locations:

- `generate-matrix/action.yml:26`

### github-env-injection (severity: high)

The `run:` block in generate-matrix/action.yml writes output derived from the unsanitized `${{ inputs.find-options }}` expression directly to `$GITHUB_OUTPUT` without applying the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker-controlled newline in the input value could inject additional key=value pairs into GITHUB_OUTPUT.

Locations:

- `generate-matrix/action.yml:23`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed generate-matrix/action.yml: (1) Moved ${{ inputs.find-options }} to an env: block as FIND_OPTIONS and used `read -ra find_args <<< "$FIND_OPTIONS"` with `"${find_args[@]}"` to safely pass options to find, eliminating script injection. (2) Captured jq output in a variable and sanitized it with `printf '%s' "$stack_yamls" | tr -d '\n\r'` before writing to $GITHUB_OUTPUT, preventing newline-based github-env-injection.

