<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action--generate-matrix/v5.7.28

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action--generate-matrix/v5.7.28** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) violation: The expression `${{ inputs.find-options }}` is interpolated directly inside a `run:` shell command on line 25. Before the shell ever executes, GitHub Actions substitutes the raw input value into the command string, allowing an attacker who controls the `find-options` input to inject arbitrary shell commands (e.g., `; malicious-command #`). The offending line is: `find ${{ inputs.find-options }} -printf "%f"\n' | sort -V | jq --slurp`

Locations:

- `action.yml:25`

### github-env-injection (severity: high)

The `run:` block writes the output of `find ${{ inputs.find-options }} ...` to `$GITHUB_OUTPUT` (line 27) without applying the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). Because `inputs.find-options` is attacker-controlled and is interpolated directly into the command, the output written to GITHUB_OUTPUT can contain embedded newlines, allowing injection of additional key=value pairs into the output context. No sanitization is applied before the heredoc write (`} >>"$GITHUB_OUTPUT"`).

Locations:

- `action.yml:27`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.find-options }}" appears directly in run: block of step "Generate"; move to env: map

Locations:

- `action.yml:26`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all three findings in action.yml by: (1) Moving `${{ inputs.find-options }}` from the run: shell command to the step's env: block as FIND_OPTIONS, eliminating direct shell interpolation. (2) Using xargs-based tokenization (with NUL-delimited read loop and guard) to safely split the FIND_OPTIONS list into a bash array, preserving argument boundaries and quoted values. (3) Capturing the find output into a variable and sanitizing it with `printf '%s' "$stack_yamls" | tr -d '\n\r'` before writing to $GITHUB_OUTPUT to prevent newline injection.

