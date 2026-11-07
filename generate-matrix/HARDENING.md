<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action--generate-matrix/v5.7.32

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action--generate-matrix/v5.7.32** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): a GitHub Actions expression is placed directly in the run: script of the 'generate' step. Offending line: `find ${{ inputs.find-options }} -printf '"%f"\n' | sort -V | jq --slurp`. The input is pasted into the script text before bash runs it, so a value containing `;`, `$(...)`, backticks or a find option like `-exec` can run any command. Fix: pass it through env (e.g. FIND_OPTIONS: ${{ inputs.find-options }}). Since it holds several find arguments, parse it into an array safely (e.g. read -ra) rather than expanding it unquoted. Also, `working-directory: ${{ inputs.working-directory }}` is not part of the script, so it is not flagged.

Locations:

- `action.yml:24`

### github-env-injection (severity: high)

The 'generate' step writes output controlled by an input to $GITHUB_OUTPUT using a fixed heredoc delimiter ('stack-yamls<<EOM' ... 'EOM'). `inputs.find-options` decides which files are listed and what find prints. The step does not sanitize that value before writing, and the delimiter is a fixed string that can be guessed, so injected text could close the block early and add extra outputs. Fix: sanitize or validate the value from the input before the write, and use a random delimiter (e.g. EOF_$(openssl rand -hex 8)) or emit compact single-line JSON (jq -c) that has been sanitized.

Locations:

- `action.yml:22`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.find-options }}" appears directly in run: block of step "Generate"; move to env: map

Locations:

- `action.yml:26`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, static-inline-injection, github-env-injection

**Notes:**

Moved inputs.find-options into env (FIND_OPTIONS). The script now splits it into a bash array with the quote-aware xargs method. This is needed because upstream pasted the expression straight into the script, so the shell read quotes in the value; the default "-type f -maxdepth 1 -name 'stack*.yaml'" still comes out as the same find arguments. If the value has an unmatched quote, the step fails instead of running with some arguments silently dropped. The fixed 'EOM' heredoc delimiter is now a random one taken from /dev/urandom each run. The multi-line jq output is written to the output unchanged. The command pipeline (find | sort -V | jq --slurp) is unchanged. working-directory was left as it was. Not tested: I didn't run the action after the edit.

