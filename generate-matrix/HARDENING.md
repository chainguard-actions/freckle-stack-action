<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action--generate-matrix/v5.7.19

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action--generate-matrix/v5.7.19** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The `run:` block directly interpolates `${{ inputs.find-options }}` into a shell command string: `find ${{ inputs.find-options }} -printf "%f"\n`. Because YAML template substitution happens before the shell sees the command, an attacker-controlled calling workflow can supply a value containing shell metacharacters (e.g., `;`, `|`, `$(...)`) to achieve arbitrary command execution. The fix is to pass the value via an `env:` variable and reference it with double-quoting: `env: FIND_OPTIONS: ${{ inputs.find-options }}` and then `find "$FIND_OPTIONS" ...`.

Locations:

- `action.yml:22`

### github-env-injection (severity: high)

The `run:` block writes to `$GITHUB_OUTPUT` using a heredoc, and the content is derived from `find ${{ inputs.find-options }} ...` — an unsanitized `inputs.*` expression interpolated directly into the shell command. The `inputs.find-options` value is not passed through `printf '%s' ... | tr -d '\n\r'` before the write to `$GITHUB_OUTPUT`, violating the github-env-injection rule. A newline embedded in the input could break the heredoc delimiter or inject additional key=value pairs into `$GITHUB_OUTPUT`.

Locations:

- `action.yml:22`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.find-options }}" appears directly in run: block of step "Generate"; move to env: map

Locations:

- `action.yml:26`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all three findings in action.yml by moving `${{ inputs.find-options }}` from the `run:` block into an `env:` variable (`FIND_OPTIONS`). Since `find-options` is an argument list (the default contains multiple tokens like `-type f -maxdepth 1 -name 'stack*.yaml'`), the shell script now uses the xargs tokenization pattern to split the value into a bash array (`find_args`) while preserving quoting semantics. The array is then passed to `find` with `"${find_args[@]}"`, keeping each argument properly separated and quoted.

