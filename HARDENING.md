<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.29

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.29** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) violation: `${{ inputs.find-options }}` is directly interpolated inside a `run:` shell command in the composite action. An attacker calling this action can supply a value like `-name x; malicious-command` to achieve arbitrary command execution. The offending line is: `find ${{ inputs.find-options }} -printf "%f"\n' | sort -V | jq --slurp`. Additionally, `${{ inputs.working-directory }}` is interpolated in the `working-directory:` field on line 22.

Locations:

- `generate-matrix/action.yml:25`

### github-env-injection (severity: high)

The `run:` block writes the output of `find ${{ inputs.find-options }}` directly to `$GITHUB_OUTPUT` without sanitization (no `printf '%s' ... | tr -d '\n\r'` step). The `inputs.find-options` value is untrusted and controlled by the calling workflow, allowing newline injection into the GitHub output file which can be used to set arbitrary output variables.

Locations:

- `generate-matrix/action.yml:27`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed generate-matrix/action.yml: moved `${{ inputs.find-options }}` from direct shell interpolation into the step's `env:` block as `FIND_OPTIONS`. Used the xargs/while-read-NUL tokenization pattern to safely split the argument list into a bash array `opts[]`, which is then passed to `find "${opts[@]}"`. This prevents both shell injection (script-injection finding) and newline injection into $GITHUB_OUTPUT (github-env-injection finding). The heredoc format for writing to $GITHUB_OUTPUT is preserved since jq --slurp produces multiline JSON. The `working-directory: ${{ inputs.working-directory }}` field is a YAML field (not a shell command) and was left unchanged.

