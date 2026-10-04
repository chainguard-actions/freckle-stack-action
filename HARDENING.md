<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.21

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.21** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): `${{ inputs.find-options }}` is directly interpolated inside a `run:` shell command in the composite action. An attacker-controlled caller can supply shell metacharacters (`;`, `|`, `$(...)`, etc.) in this input to execute arbitrary commands. The offending line is: `find ${{ inputs.find-options }} -printf "%f"\n' | sort -V | jq --slurp`. The value should be passed via an `env:` variable and double-quoted in the shell script instead.

Locations:

- `generate-matrix/action.yml:25`

### github-env-injection (severity: high)

The `run:` block writes output derived from the untrusted input `${{ inputs.find-options }}` directly to `$GITHUB_OUTPUT` without sanitization (`printf '%s' ... | tr -d '\n\r'`). Because `inputs.find-options` is interpolated directly into the `find` command whose stdout is redirected into `$GITHUB_OUTPUT`, a newline embedded in the input value can inject arbitrary key=value pairs into the GitHub output environment. The offending block ends with `} >> "$GITHUB_OUTPUT"`.

Locations:

- `generate-matrix/action.yml:27`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed generate-matrix/action.yml: moved `${{ inputs.find-options }}` from direct shell interpolation into an `env:` variable `FIND_OPTIONS`. Since find-options is an argument list (e.g., `-type f -maxdepth 1 -name 'stack*.yaml'`), used the xargs-based tokenization pattern to safely split it into a bash array `find_opts[]`, which is then passed to `find` with proper quoting. This eliminates both the script-injection risk (no more direct expression interpolation in the shell) and the github-env-injection risk (the untrusted input no longer flows directly into the GITHUB_OUTPUT write path).

