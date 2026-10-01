<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.30

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.30** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The `run:` block in generate-matrix/action.yml directly interpolates the untrusted input expression `${{ inputs.find-options }}` into a shell command on line 25: `find ${{ inputs.find-options }} -printf "%f"\n`. A caller can supply a value like `-type f; malicious-command` to execute arbitrary shell commands. Additionally, `${{ inputs.working-directory }}` is interpolated into the `working-directory:` field (line 22), though the primary injection risk is in the `run:` block itself.

Locations:

- `generate-matrix/action.yml:25`

### github-env-injection (severity: high)

The `run:` block in generate-matrix/action.yml writes output derived from the untrusted input `${{ inputs.find-options }}` to `$GITHUB_OUTPUT` (line 27) using a heredoc, without applying the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). A newline character embedded in `inputs.find-options` could inject additional key=value pairs into GITHUB_OUTPUT, allowing an attacker to override subsequent step outputs.

Locations:

- `generate-matrix/action.yml:25`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed hardened/action/generate-matrix/action.yml: moved `${{ inputs.find-options }}` from the `run:` shell block into the step's `env:` block as `FIND_OPTIONS`. The shell script now uses the xargs/read-loop pattern to safely tokenize the argument list into a bash array (`find_args`), which is passed to `find` with proper quoting. This eliminates both the shell command injection risk and the GITHUB_OUTPUT injection risk, since the untrusted value is no longer interpolated directly into the shell script text.

