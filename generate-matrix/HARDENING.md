<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action--generate-matrix/v5.7.30

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action--generate-matrix/v5.7.30** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) violation: `${{ inputs.find-options }}` is interpolated directly inside a `run:` shell command string. Before the shell executes, GitHub Actions substitutes the raw input value into the command, allowing an attacker who controls `find-options` to inject arbitrary shell commands. Offending line: `find ${{ inputs.find-options }} -printf "%f"\n' | sort -V | jq --slurp`. The fix is to pass the value via an `env:` variable and double-quote it: `env: FIND_OPTIONS: ${{ inputs.find-options }}` then `find $FIND_OPTIONS ...` (with `"$FIND_OPTIONS"` properly quoted).

Locations:

- `action.yml:22`

### github-env-injection (severity: high)

The `run:` block writes output derived from the untrusted input `${{ inputs.find-options }}` directly into `$GITHUB_OUTPUT` via a heredoc, without applying the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker-controlled newline in `find-options` can inject arbitrary key=value pairs into `$GITHUB_OUTPUT`, potentially overwriting other outputs consumed by downstream steps. The entire `find ... | sort -V | jq --slurp` pipeline result is written unsanitized to `$GITHUB_OUTPUT`.

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

Fixed all three findings in action.yml by: (1) Moving `${{ inputs.find-options }}` out of the `run:` block into an `env:` variable `FIND_OPTIONS`; (2) Using xargs-based tokenization (`while IFS= read -r -d '' t; do find_opts+=("$t"); done < <(printf '%s' "$FIND_OPTIONS" | xargs printf '%s\0')`) to properly split the argument list while preserving quoting; (3) Capturing the `find | sort | jq` pipeline output into a variable and sanitizing it with `tr -d '\n\r'` before writing to `$GITHUB_OUTPUT` using `printf 'stack-yamls=%s\n'` instead of a heredoc.

