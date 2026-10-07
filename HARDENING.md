<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.31

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.31** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The `run:` block in generate-matrix/action.yml directly interpolates `${{ inputs.find-options }}` inside a shell command string. This allows an attacker (or any caller of this composite action) to inject arbitrary shell commands via the `find-options` input. The offending line is: `find ${{ inputs.find-options }} -printf "%f"\n' | sort -V | jq --slurp`

Locations:

- `generate-matrix/action.yml:25`

### github-env-injection (severity: high)

The `run:` block writes the output of `find ${{ inputs.find-options }} ...` directly to `$GITHUB_OUTPUT` without sanitization (no `printf '%s' ... | tr -d '\n\r'` step). The `inputs.find-options` value is attacker-controlled and flows unsanitized into the GITHUB_OUTPUT special file, enabling newline injection that could define arbitrary output variables.

Locations:

- `generate-matrix/action.yml:25`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed generate-matrix/action.yml: moved `${{ inputs.find-options }}` from the shell `run:` block into an `env:` block as `FIND_OPTIONS`. Since `find-options` is a list-style input (space-separated arguments to find(1)), used the xargs-based tokenization pattern (`while IFS= read -r -d '' t; do find_opts+=("$t"); done < <(printf '%s' "$FIND_OPTIONS" | xargs printf '%s\0')`) to safely split it into a bash array, then expanded the array as `"${find_opts[@]}"` in the find command. This prevents both shell command injection and newline injection into $GITHUB_OUTPUT.

