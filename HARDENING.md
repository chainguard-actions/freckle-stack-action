<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.32

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.32** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): an expression is placed directly inside a run: script in generate-matrix/action.yml. The offending line is `find ${{ inputs.find-options }} -printf '"%f"\n' | sort -V | jq --slurp`. GitHub substitutes inputs.find-options into the script text before the shell runs, and it is not quoted, so shell metacharacters in it (;, |, $(...), backticks) run as commands. To fix it, pass the input through env: (for example FIND_OPTIONS: ${{ inputs.find-options }}) and handle it safely in the script, for example by reading it into a bash array, without using eval.

Locations:

- `generate-matrix/action.yml:25`

### github-env-injection (severity: high)

The Generate step writes to $GITHUB_OUTPUT (`echo 'stack-yamls<<EOM'` ... `} >>"$GITHUB_OUTPUT"`) the output of a find command whose arguments come entirely from inputs.find-options. The value is not passed through the required `printf '%s' ... | tr -d '\n\r'` before the write. Because the caller controls what runs and what it prints inside the heredoc, it can end the EOM block early and inject extra step outputs.

Locations:

- `generate-matrix/action.yml:23`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

generate-matrix/action.yml: inputs.find-options moved to env FIND_OPTIONS and tokenized with the quote-aware xargs split (preserves upstream's shell quoting e.g. -name 'stack*.yaml'), passed to find as an array. The multi-line JSON output is captured first (errexit/pipefail preserved) and written to GITHUB_OUTPUT using a random per-run heredoc delimiter from /dev/urandom instead of the fixed 'EOM'.

