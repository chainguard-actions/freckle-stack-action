<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.28

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.28** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): `${{ inputs.find-options }}` is directly interpolated inside a `run:` shell command in the composite action. An attacker-controlled value for `inputs.find-options` can inject arbitrary shell commands. Offending line: `find ${{ inputs.find-options }} -printf "%f"\n' | sort -V | jq --slurp`

Locations:

- `generate-matrix/action.yml:25`

### github-env-injection (severity: high)

The `run:` block writes to `$GITHUB_OUTPUT` (via a heredoc) using output derived from `${{ inputs.find-options }}` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker-controlled newline in `inputs.find-options` can inject additional key=value pairs into `$GITHUB_OUTPUT`, potentially overwriting outputs consumed by downstream steps.

Locations:

- `generate-matrix/action.yml:25`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed generate-matrix/action.yml: moved `${{ inputs.find-options }}` into the step's `env:` block as `FIND_OPTIONS`. Added newline sanitization (`tr -d '\n\r'`) to prevent github-env-injection. Used xargs-based quote-aware tokenization into a bash array (`find_opts`) since `find-options` is a list of arguments, then expanded it as `"${find_opts[@]}"` when calling `find`. The guard `if [ -n "$FIND_OPTIONS" ]` prevents xargs from emitting an empty token on empty input.

