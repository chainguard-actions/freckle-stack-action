<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action--generate-matrix/v5.7.21

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action--generate-matrix/v5.7.21** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The `run:` block in the 'generate' step directly interpolates `${{ inputs.find-options }}` into the shell command string: `find ${{ inputs.find-options }} -printf ...`. Because GitHub Actions performs template substitution before the shell parses the command, an attacker who controls the `find-options` input can inject arbitrary shell commands (e.g., by supplying a value like `. ; malicious-command`). The value must be passed via an `env:` variable and double-quoted in the shell instead.

Locations:

- `action.yml:21`

### github-env-injection (severity: high)

The `run:` block writes to `$GITHUB_OUTPUT` using a heredoc whose content is derived from `find ${{ inputs.find-options }} ...`. The untrusted `inputs.find-options` value is interpolated directly into the shell command and its output is written to `$GITHUB_OUTPUT` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). A malicious input containing newlines could inject additional key=value pairs into `$GITHUB_OUTPUT`, poisoning downstream step outputs.

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

Fixed all three findings in action.yml by: (1) Moving `${{ inputs.find-options }}` from the run: block into an env: variable (FIND_OPTIONS); (2) Tokenizing FIND_OPTIONS with xargs into a bash array to properly handle the list-style input (e.g., `-type f -maxdepth 1 -name 'stack*.yaml'`); (3) Replacing the heredoc GITHUB_OUTPUT write with a sanitized printf that strips newlines/carriage returns via `tr -d '\n\r'` before writing the stack-yamls output value.

