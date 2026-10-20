<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.33

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.33** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): The `run:` block in generate-matrix/action.yml directly interpolates `${{ inputs.find-options }}` into a shell command string. An attacker who calls this composite action can supply a malicious value for `find-options` (e.g., `"; malicious-command"`) to achieve arbitrary command execution on the runner. The offending line is: `find ${{ inputs.find-options }} -printf '"%f"\n' | sort -V | jq --slurp`. The `inputs.find-options` value must be passed via an `env:` block and the shell variable must be double-quoted, or the argument must be validated before use.

Locations:

- `generate-matrix/action.yml:20`

### github-env-injection (severity: high)

The `run:` block in generate-matrix/action.yml writes to `$GITHUB_OUTPUT` using a heredoc that includes the output of `find ${{ inputs.find-options }}`. The `inputs.find-options` value is directly interpolated (no sanitization via `printf '%s' ... | tr -d '\n\r'`) before being written to the special environment file `$GITHUB_OUTPUT`. This allows an attacker-controlled input to inject arbitrary key-value pairs into the GitHub output context.

Locations:

- `generate-matrix/action.yml:19`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed generate-matrix/action.yml: (1) Moved `${{ inputs.find-options }}` to the `env:` block as `FIND_OPTIONS` and used xargs-based quote-aware tokenization into a bash array `find_args` to prevent script injection — the `find` command now uses `"${find_args[@]}"` with each argument properly quoted and separate. A `xargs -r true` guard ensures the step fails on unmatched quotes. (2) Replaced the fixed heredoc delimiter `EOM` with a random one generated from `/dev/urandom` (`EOF_$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')`) to prevent github-env-injection via delimiter collision.

