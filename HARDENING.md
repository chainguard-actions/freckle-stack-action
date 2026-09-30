<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.28

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.28** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The `run:` block in generate-matrix/action.yml directly interpolates `${{ inputs.find-options }}` inside a shell command string on line 25: `find ${{ inputs.find-options }} -printf "%f"\n`. This allows an attacker who controls the `find-options` input to inject arbitrary shell commands. The expression is substituted by the Actions runner before the shell ever sees the string, bypassing any quoting. The `working-directory` field also uses `${{ inputs.working-directory }}` but that is a YAML field, not a shell run block.

Locations:

- `generate-matrix/action.yml:25`

### github-env-injection (severity: high)

The `run:` block writes to `$GITHUB_OUTPUT` on line 27 using content produced by `find ${{ inputs.find-options }}`. The value of `inputs.find-options` is interpolated directly into the shell command (no sanitization via `printf '%s' | tr -d '\n\r'`) and the output of that command — which can contain attacker-controlled newlines — is written verbatim to `$GITHUB_OUTPUT`. This allows an attacker to inject arbitrary key=value pairs into the GitHub output environment.

Locations:

- `generate-matrix/action.yml:27`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed generate-matrix/action.yml: moved ${{ inputs.find-options }} from the shell run block into an env: block as FIND_OPTIONS. The value is then safely tokenized using xargs into a bash array (find_args) with the standard IFS/read/while loop pattern, which handles quoted arguments like "-name 'stack*.yaml'" without allowing shell injection. The heredoc (<<EOM) format for writing to $GITHUB_OUTPUT already safely contains newlines in the find output, and removing the direct expression interpolation eliminates the github-env-injection vector.

