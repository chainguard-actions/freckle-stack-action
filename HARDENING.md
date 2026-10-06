<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.23

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.23** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The `run:` block in generate-matrix/action.yml directly interpolates `${{ inputs.find-options }}` into a shell command (`find ${{ inputs.find-options }} -printf ...`). This allows an attacker who controls the `find-options` input to inject arbitrary shell commands. The expression is substituted by the Actions runner before the shell ever sees the string, bypassing any quoting. The value should be passed via an `env:` variable and then double-quoted in the shell: `env: FIND_OPTIONS: ${{ inputs.find-options }}` and `find "$FIND_OPTIONS" ...`.

Locations:

- `generate-matrix/action.yml:25`

### github-env-injection (severity: high)

The `run:` block in generate-matrix/action.yml writes the output of `find ${{ inputs.find-options }} ...` directly to `$GITHUB_OUTPUT` using a heredoc (`echo 'stack-yamls<<EOM' ... >> "$GITHUB_OUTPUT"`). Because `inputs.find-options` is attacker-controlled and is interpolated unsanitized into the shell command, the content written to GITHUB_OUTPUT can contain newlines or other control characters that allow injection of additional key=value pairs into the output file. The value must be sanitized with `printf '%s' ... | tr -d '\n\r'` before being written to the special environment file.

Locations:

- `generate-matrix/action.yml:23`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed hardened/action/generate-matrix/action.yml: (1) Moved `${{ inputs.find-options }}` to an env var `FIND_OPTIONS` and tokenized it with xargs into a bash array `find_opts`, then used `"${find_opts[@]}"` in the find command to prevent script injection. (2) Captured the find/sort/jq pipeline output into `stack_yamls`, sanitized it with `printf '%s' "$stack_yamls" | tr -d '\n\r'` into `safe_stack_yamls`, and wrote only the sanitized value to $GITHUB_OUTPUT to prevent github-env-injection.

