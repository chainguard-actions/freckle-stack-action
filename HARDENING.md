<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.33

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.33** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): the run: block puts the expression straight into the shell command: `find ${{ inputs.find-options }} -printf '"%f"\n' | sort -V | jq --slurp`. The caller-supplied find-options input is pasted into the bash script before the shell runs. Someone can inject shell metacharacters (e.g. `; curl ... ;`) or find actions such as -exec or -delete. Move it to an env: variable. Because find-options is a list of arguments, parse it safely (e.g. read it into a bash array), and do not expand an unquoted ${{ }} expression.

Locations:

- `generate-matrix/action.yml:25`

### github-env-injection (severity: high)

The step writes output built from the untrusted inputs.find-options to $GITHUB_OUTPUT inside a fixed 'EOM' heredoc, with no `printf '%s' ... | tr -d '\n\r'` cleanup first. The input decides which files are matched and what is printed. A filename or injected output that contains newlines and the line 'EOM' can end the heredoc early and set extra step outputs.

Locations:

- `generate-matrix/action.yml:23`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

generate-matrix/action.yml: inputs.find-options now goes through env FIND_OPTIONS. It is split into a bash array the same way upstream's shell split it, honoring quotes, using the guarded xargs split (with the 'xargs -r true' check for unmatched quotes), and passed to find as "${find_args[@]}". So the default -name 'stack*.yaml' still reaches find as the single word stack*.yaml. The fixed EOM heredoc delimiter is now random for each run (EOM_ followed by 16 bytes from /dev/urandom). The multi-line JSON value is written unchanged.

