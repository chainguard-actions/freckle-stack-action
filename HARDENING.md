<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.18

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.18** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

In generate-matrix/action.yml, the `run:` block directly interpolates `${{ inputs.find-options }}` into a shell command (rule a: direct expression interpolation). An attacker-controlled caller can supply shell metacharacters or malicious arguments via the `find-options` input, enabling arbitrary command execution. The offending line is: `find ${{ inputs.find-options }} -printf "%f"\n' | sort -V | jq --slurp`

Locations:

- `generate-matrix/action.yml:25`

### github-env-injection (severity: high)

In generate-matrix/action.yml, the `run:` block writes the output of `find ${{ inputs.find-options }} ...` to `$GITHUB_OUTPUT` using a heredoc (`>> "$GITHUB_OUTPUT"`). The value is derived from the untrusted `inputs.find-options` input without any sanitization (`printf '%s' ... | tr -d '\n\r'`). A caller can inject newlines or key=value pairs into GITHUB_OUTPUT, potentially poisoning downstream step outputs.

Locations:

- `generate-matrix/action.yml:27`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed generate-matrix/action.yml: (1) Moved `${{ inputs.find-options }}` from the run: shell command into the step's env: block as FIND_OPTIONS, then tokenized it with xargs into a bash array (find_opts) to safely pass as arguments to find — this prevents shell metacharacter injection while correctly handling quoted arguments like the default `-name 'stack*.yaml'`. (2) Captured the jq output into a variable and sanitized it with `printf '%s' "$stack_yamls" | tr -d '\n\r'` before writing to $GITHUB_OUTPUT via heredoc, preventing newline/key=value injection into downstream step outputs.

