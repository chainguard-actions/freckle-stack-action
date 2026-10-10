<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.19

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.19** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The `run:` block in `generate-matrix/action.yml` directly interpolates `${{ inputs.find-options }}` inside a shell command string: `find ${{ inputs.find-options }} -printf "%f"\n | sort -V | jq --slurp`. An attacker-controlled value for `inputs.find-options` (e.g. containing shell metacharacters, semicolons, or command substitution) is passed directly to the shell before any quoting or escaping, enabling arbitrary command injection.

Locations:

- `generate-matrix/action.yml:25`

### github-env-injection (severity: high)

The same `run:` step writes to `$GITHUB_OUTPUT` via a heredoc, and the content is derived from `${{ inputs.find-options }}` interpolated directly into the shell command without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker-controlled `inputs.find-options` value containing newlines could inject arbitrary key=value pairs into `$GITHUB_OUTPUT`, poisoning downstream step outputs.

Locations:

- `generate-matrix/action.yml:25`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed hardened/action/generate-matrix/action.yml: moved `${{ inputs.find-options }}` from the shell command string into the step's `env:` block as `FIND_OPTIONS`. Since find-options is a list of arguments (e.g., `-type f -maxdepth 1 -name 'stack*.yaml'`), used the xargs tokenization pattern to safely split it into a bash array `find_args`, which is then passed to `find` as `"${find_args[@]}"`. Added the required `if [ -n "$FIND_OPTIONS" ]` guard to prevent xargs from emitting an empty token on empty input. The GITHUB_OUTPUT content comes from find's output (filenames), not from the user-controlled input, so the main fix is preventing shell injection via the find command arguments.

