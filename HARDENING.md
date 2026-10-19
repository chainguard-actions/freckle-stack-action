<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.32

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.32** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The `run:` block in `generate-matrix/action.yml` directly interpolates `${{ inputs.find-options }}` inside a shell command string. This allows an attacker (or any caller of this composite action) to inject arbitrary shell commands via the `find-options` input. The offending line is: `find ${{ inputs.find-options }} -printf "%f"\n' | sort -V | jq --slurp`. The value is substituted by the Actions template engine before the shell ever sees it, bypassing any quoting.

Locations:

- `generate-matrix/action.yml:25`

### github-env-injection (severity: high)

The `run:` block in `generate-matrix/action.yml` writes data derived from the untrusted input `${{ inputs.find-options }}` to `$GITHUB_OUTPUT` without applying the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). The heredoc block pipes the output of `find ${{ inputs.find-options }} ...` directly into `$GITHUB_OUTPUT`. A caller-controlled newline or special sequence in `find-options` could inject additional key=value pairs into the output file, potentially overwriting subsequent outputs or poisoning the environment of downstream steps.

Locations:

- `generate-matrix/action.yml:23`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed generate-matrix/action.yml: (1) Moved `${{ inputs.find-options }}` to the step's `env:` block as `FIND_OPTIONS` to prevent script injection — the shell now references `$FIND_OPTIONS` and tokenizes it into an array with `read -r -d '' -a` (whitespace split, matching upstream's unquoted expansion). (2) Replaced the fixed heredoc delimiter `EOM` with a randomly generated one (`EOF_$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')`) to prevent heredoc injection attacks on `$GITHUB_OUTPUT`.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

Fixed generate-matrix/action.yml line 28: replaced `read -r -d '' -a find_args <<< "$FIND_OPTIONS" || true` (whitespace-only split, ignores quotes) with the xargs-based tokenization approach. The new code: (1) guards with `[ -n "$FIND_OPTIONS" ]`, (2) runs `printf '%s' "$FIND_OPTIONS" | xargs -r true` to fail on unmatched quotes, and (3) uses a while/read loop with `< <(printf '%s' "$FIND_OPTIONS" | xargs -r printf '%s\0')` to properly tokenize the value into an array honoring shell quoting. This matches how upstream interpolated the input unquoted, where the shell split it into several arguments while respecting quotes (e.g., `-name 'stack*.yaml'` becomes two arguments: `-name` and `stack*.yaml`).

