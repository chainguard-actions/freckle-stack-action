<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action--generate-matrix/v5.7.29

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action--generate-matrix/v5.7.29** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a) and (b): The `run:` block in the `generate` step directly interpolates `${{ inputs.find-options }}` into the shell command string: `find ${{ inputs.find-options }} -printf ...`. This allows an attacker-controlled input to inject arbitrary shell commands (e.g. by passing `; malicious-command #` as the input value). The expression is also unquoted, allowing shell metacharacter splitting. The value should be passed via an `env:` variable and double-quoted: `env: FIND_OPTIONS: ${{ inputs.find-options }}` then `find "$FIND_OPTIONS" ...`.

Locations:

- `action.yml:23`

### github-env-injection (severity: high)

The `run:` block writes to `$GITHUB_OUTPUT` using a heredoc that includes the output of `find ${{ inputs.find-options }} ...`. The `inputs.find-options` value is interpolated directly into the shell command without sanitization (no `printf '%s' ... | tr -d '\n\r'` applied before the write). A malicious input containing newlines could inject arbitrary key=value pairs into `$GITHUB_OUTPUT`, potentially poisoning downstream steps that consume the `stack-yamls` output.

Locations:

- `action.yml:23`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.find-options }}" appears directly in run: block of step "Generate"; move to env: map

Locations:

- `action.yml:26`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all three findings in hardened/action/action.yml:
1. Moved `${{ inputs.find-options }}` from the run: block to an env: variable `FIND_OPTIONS`.
2. Used xargs tokenization into a bash array (`find_opts`) to properly handle the space-separated list of find arguments while preserving quoting.
3. Used `jq -c --slurp` for compact single-line JSON output.
4. Sanitized the output with `tr -d '\n\r'` before writing to $GITHUB_OUTPUT via `printf` to prevent newline injection attacks.

