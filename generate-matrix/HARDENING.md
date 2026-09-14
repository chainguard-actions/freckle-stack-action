<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action--generate-matrix/v5.7.29

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action--generate-matrix/v5.7.29** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) violation: `${{ inputs.find-options }}` is directly interpolated inside a `run:` shell command on line 26: `find ${{ inputs.find-options }} -printf "%f"\n`. A caller can supply shell metacharacters or subcommands (e.g. `; malicious-command`) as the `find-options` input, which will be executed by bash before any quoting can protect the runner. The value must be passed via an `env:` variable and then double-quoted in the shell script instead.

Locations:

- `action.yml:26`

### github-env-injection (severity: high)

The `run:` block writes to `$GITHUB_OUTPUT` (line 29) using a heredoc whose content is derived from `find ${{ inputs.find-options }} ...` (line 26). The `inputs.find-options` value is an untrusted caller-controlled input that flows unsanitized into `$GITHUB_OUTPUT`. No `printf '%s' ... | tr -d '\n\r'` sanitization is applied before the write, allowing newline injection that could smuggle additional key=value pairs into the GitHub output environment.

Locations:

- `action.yml:26`
- `action.yml:29`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.find-options }}" appears directly in run: block of step "Generate"; move to env: map

Locations:

- `action.yml:26`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed action.yml step 'Generate': moved `${{ inputs.find-options }}` from the run: block into an env: variable (FIND_OPTIONS). Since find-options is a list of arguments, used xargs-based tokenization into a bash array (find_opts) with a guarded if-block to handle empty values. Captured find output in $result, sanitized with `tr -d '\n\r'` into $safe, and wrote to $GITHUB_OUTPUT using simple key=value form instead of a heredoc, preventing newline injection.

