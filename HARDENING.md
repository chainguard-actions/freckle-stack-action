<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.16

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.16** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The `run:` block in generate-matrix/action.yml directly interpolates `${{ inputs.find-options }}` inside a shell command string. This allows an attacker who controls the `find-options` input to inject arbitrary shell commands. The offending line is: `find ${{ inputs.find-options }} -printf "%f"\n' | sort -V | jq --slurp`

Locations:

- `generate-matrix/action.yml:25`

### github-env-injection (severity: high)

The `run:` block in generate-matrix/action.yml writes the output of `find ${{ inputs.find-options }} ...` directly to `$GITHUB_OUTPUT` without any sanitization (no `printf '%s' ... | tr -d '\n\r'` step). The `inputs.find-options` value is attacker-controlled and is interpolated directly into the shell command whose output is redirected to `$GITHUB_OUTPUT`, enabling newline injection to set arbitrary output variables.

Locations:

- `generate-matrix/action.yml:25`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed generate-matrix/action.yml: (1) Moved `${{ inputs.find-options }}` out of the shell command string into an `env:` block as `FIND_OPTIONS` to prevent script injection. (2) Used xargs-based array tokenization to safely split the find-options argument list into individual arguments while preserving quoting. (3) Captured the jq output into a variable and sanitized it with `tr -d '\r'` before writing to $GITHUB_OUTPUT to prevent newline injection attacks.

