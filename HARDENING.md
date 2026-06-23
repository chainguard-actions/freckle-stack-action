<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.18

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **freckle--stack-action/v5.7.18** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): The `run:` block in `generate-matrix/action.yml` directly interpolates `${{ inputs.find-options }}` inside a shell command: `find ${{ inputs.find-options }} -printf "%f"\n`. An attacker controlling the `find-options` input can inject arbitrary shell commands (e.g., passing `; malicious-command #` as the input value). The value is substituted by the YAML template engine before the shell ever sees it, bypassing any quoting.

Locations:

- `generate-matrix/action.yml:25`

### github-env-injection (severity: high)

The `run:` block in `generate-matrix/action.yml` writes data derived from the untrusted input `${{ inputs.find-options }}` to `$GITHUB_OUTPUT` without sanitization. The `find` command output (whose arguments are controlled by the caller via `inputs.find-options`) is piped into the heredoc written to `$GITHUB_OUTPUT`. No `printf '%s' ... | tr -d '\n\r'` sanitization is applied before the write.

Locations:

- `generate-matrix/action.yml:26`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed generate-matrix/action.yml: (1) Moved ${{ inputs.find-options }} into the step's env: block as FIND_OPTIONS and referenced it as $FIND_OPTIONS in the shell command, eliminating direct template interpolation into the shell string. (2) Replaced the heredoc write to $GITHUB_OUTPUT with a sanitized approach: captured find output into a variable, stripped newlines with tr -d '\n\r', and wrote using printf with a fixed format string to prevent newline injection.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in generate-matrix/action.yml line 23. The unquoted `find $FIND_OPTIONS` was replaced with `read -ra find_opts <<< "$FIND_OPTIONS"` followed by `find "${find_opts[@]}"`. This reads the env var as a quoted string and splits it into an array using word-splitting only (not shell metacharacter interpretation), then expands each array element as a properly quoted argument. Shell metacharacters like `;`, `|`, `&`, `$(...)` embedded in the input value will no longer be interpreted by the shell.

