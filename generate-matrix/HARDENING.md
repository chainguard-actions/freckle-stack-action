<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action--generate-matrix/v5.7.33

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action--generate-matrix/v5.7.33** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) violation: The `run:` block directly interpolates `${{ inputs.find-options }}` into a shell command. Before the shell executes the script, the Actions runner substitutes this expression with the raw input value, allowing an attacker to inject arbitrary shell commands by supplying metacharacters (e.g., `;`, `&&`, `$(...)`) in the `find-options` input. The offending line is: `find ${{ inputs.find-options }} -printf "%f\n" | sort -V | jq --slurp`. The fix is to pass the input via an `env:` variable and double-quote the expansion: set `env: FIND_OPTIONS: ${{ inputs.find-options }}` and use `find $FIND_OPTIONS` → `find "$FIND_OPTIONS"` in the script.

Locations:

- `action.yml:26`

### github-env-injection (severity: high)

The `run:` block writes to `$GITHUB_OUTPUT` (line 28) using a heredoc whose content is derived from `find ${{ inputs.find-options }} ...`. The untrusted `inputs.find-options` value flows — without sanitization (`printf '%s' ... | tr -d '\n\r'`) — into `$GITHUB_OUTPUT`. A malicious input containing newlines could inject additional key=value pairs into the output context, potentially overwriting other step outputs. The fix requires sanitizing the value before it is written to `$GITHUB_OUTPUT`.

Locations:

- `action.yml:28`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.find-options }}" appears directly in run: block of step "Generate"; move to env: map

Locations:

- `action.yml:26`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all three findings in hardened/action/action.yml:
1. Moved `${{ inputs.find-options }}` from the run: block to an env: variable `FIND_OPTIONS` to prevent script injection.
2. Split FIND_OPTIONS into an array using `read -r -d '' -a find_args <<< "$FIND_OPTIONS" || true` (whitespace split matching upstream's unquoted usage), then passed as `"${find_args[@]}"` to find.
3. Replaced the fixed heredoc delimiter `EOM` with a random one from /dev/urandom to prevent github-env-injection via newlines in the output value. The multi-line jq output is preserved as-is in the heredoc (correct for multi-line values per policy).

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

Fixed action.yml line 28: replaced `read -r -d '' -a find_args <<< "$FIND_OPTIONS" || true` with the xargs-based tokenization approach. The upstream action interpolated the `find-options` input as an unquoted `${{ }}` expression, so the shell honored quotes in the value (e.g., `-name 'stack*.yaml'` becomes two tokens: `-name` and `stack*.yaml`). The new approach uses `printf '%s' "$FIND_OPTIONS" | xargs -r true` to fail on unmatched quotes, then `while IFS= read -r -d '' t; do find_args+=("$t"); done < <(printf '%s' "$FIND_OPTIONS" | xargs -r printf '%s\0')` to tokenize the value into an array with proper quote handling. The `[ -n "$FIND_OPTIONS" ]` guard ensures an empty input produces no arguments.

