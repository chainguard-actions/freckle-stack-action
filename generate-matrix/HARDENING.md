<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action--generate-matrix/v5.7.18

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action--generate-matrix/v5.7.18** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The `run:` block in the `generate` step directly interpolates `${{ inputs.find-options }}` into the shell command string: `find ${{ inputs.find-options }} -printf "%f"\n | sort -V | jq --slurp`. Because GitHub Actions performs template substitution before the shell parses the command, an attacker who controls the `find-options` input can inject arbitrary shell commands (e.g., by supplying a value like `. ; malicious-command`). The fix is to pass the input via an `env:` variable and double-quote it in the shell: `env: FIND_OPTIONS: ${{ inputs.find-options }}` then `find "$FIND_OPTIONS" ...`.

Locations:

- `action.yml:21`

### github-env-injection (severity: high)

The `run:` block writes to `$GITHUB_OUTPUT` using a heredoc whose content is derived from `find ${{ inputs.find-options }} ...`. The untrusted `inputs.find-options` value is interpolated directly into the shell command that produces output written to `$GITHUB_OUTPUT`, with no sanitization step (`printf '%s' ... | tr -d '\n\r'`) applied before the write. An attacker-controlled newline in the input could inject additional key=value pairs into `$GITHUB_OUTPUT`.

Locations:

- `action.yml:21`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.find-options }}" appears directly in run: block of step "Generate"; move to env: map

Locations:

- `action.yml:26`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all three findings in action.yml by: (1) Moving `${{ inputs.find-options }}` from the run: block to an `env:` variable `FIND_OPTIONS`; (2) Using xargs-based tokenization to safely expand the argument list into a bash array `find_args` (since find-options is a whitespace-separated list of arguments); (3) Using `jq --compact-output` for single-line JSON output; (4) Sanitizing the output with `printf '%s' ... | tr -d '\n\r'` before writing to `$GITHUB_OUTPUT` to prevent newline injection. The xargs tokenization includes the required empty-value guard (`if [ -n "$FIND_OPTIONS" ]`) to prevent xargs from emitting an empty argument when the variable is empty.

