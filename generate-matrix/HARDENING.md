<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action--generate-matrix/v5.7.33

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action--generate-matrix/v5.7.33** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a), direct expression interpolation, in the composite step 'generate'. The line `find ${{ inputs.find-options }} -printf '"%f"\n' | sort -V | jq --slurp` puts the inputs.find-options expression directly into the bash script. The value is substituted into the script text before bash runs, and it is also unquoted, so a caller can inject shell syntax such as `; curl ... ` or `$(...)`. Find options can also run commands on their own (e.g. -exec). Fix: pass the input through an env: variable and parse it safely, for example `read -ra FIND_OPTS <<< "$FIND_OPTIONS"; find "${FIND_OPTS[@]}" ...`, or drop the free-form find-options input.

Locations:

- `action.yml:25`

### github-env-injection (severity: high)

The 'generate' step writes output controlled by inputs.find-options to $GITHUB_OUTPUT using a fixed heredoc delimiter ('stack-yamls<<EOM' ... 'EOM'). No `printf '%s' ... | tr -d '\n\r'` sanitization is done first. Because the caller controls the find arguments (for example `-printf 'EOM\nother=value\n'` or -exec), the caller can print the delimiter followed by extra lines and inject arbitrary step outputs. Fix: compute the JSON value, sanitize it (or use a random delimiter), and validate the find options.

Locations:

- `action.yml:23`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.find-options }}" appears directly in run: block of step "Generate"; move to env: map

Locations:

- `action.yml:26`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Moved inputs.find-options into env FIND_OPTIONS and split it into a bash array with the quote-aware xargs method. Upstream pasted the expression straight into the script, so quoted values like the default -name 'stack*.yaml' are still read the same way, but nothing in the value is run as shell code. The fixed 'EOM' heredoc delimiter for $GITHUB_OUTPUT is now a random one generated each run from /dev/urandom. The multi-line JSON value is written unchanged. Not changed: callers can still pass find's own actions (e.g. -exec), because the input is meant to take any find arguments; restricting it would change how the action works.

