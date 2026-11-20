<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action--generate-matrix/v5.7.31

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action--generate-matrix/v5.7.31** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): the expression ${{ inputs.find-options }} is placed directly into the run: script on the line `find ${{ inputs.find-options }} -printf '"%f"\n' | sort -V | jq --slurp`. The runner substitutes the input's text before bash reads the script, so a caller can put shell metacharacters in it (for example `; curl ... ;` or `$(...)`) and run any command. Fix: pass the input in through an env: variable such as FIND_OPTIONS. Because the input is meant to be a whitespace-separated list of find arguments, split it with `# shellcheck disable=SC2206` followed by `FIND_ARGS=($FIND_OPTIONS)`, then run `find "${FIND_ARGS[@]}" ...`.

Locations:

- `action.yml:25`

### github-env-injection (severity: high)

Rule (f): the step writes a multi-line value to $GITHUB_OUTPUT between fixed heredoc delimiters (`echo 'stack-yamls<<EOM'` ... `echo 'EOM'`). The value comes from `find` run with the caller-controlled inputs.find-options in the caller-controlled inputs.working-directory, so it contains file names the caller controls. A file name that makes an output line equal to `EOM` would end the block early, and every line after it would be read as a new output entry. Fix: build the delimiter from a secure random source on every run, for example `EOF="EOF_$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')"`.

Locations:

- `action.yml:24`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.find-options }}" appears directly in run: block of step "Generate"; move to env: map

Locations:

- `action.yml:26`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed action.yml without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/generate-matrix/action.yml b/generate-matrix/action.yml
index fd7eb39..2fbb565 100644
--- a/generate-matrix/action.yml
+++ b/generate-matrix/action.yml
@@ -16,13 +16,37 @@ outputs:
 runs:
   using: composite
   steps:
     - id: generate
       name: Generate
       shell: bash
       working-directory: ${{ inputs.working-directory }}
+      env:
+        FIND_OPTIONS: ${{ inputs.find-options }}
       run: |
+        find_args=()
+        if [ -n "$FIND_OPTIONS" ]; then
+          while IFS= read -r -d '' t; do find_args+=("$t"); done \
+            < <(printf '%s' "$FIND_OPTIONS" | xargs printf '%s\0')
+        fi
         {
           echo 'stack-yamls<<EOM'
-          find ${{ inputs.find-options }} -printf '"%f"\n' | sort -V | jq --slurp
+          find "${find_args[@]}" -printf '"%f"\n' | sort -V | jq --slurp
           echo 'EOM'
         } >>"$GITHUB_OUTPUT"

```

Locations:

- `action.yml`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, static-inline-injection, github-env-injection, prior-fix

**Notes:**

Moved inputs.find-options into env FIND_OPTIONS. It is now split into a bash array with the quote-aware xargs method, guarded by a check that fails on an unmatched quote. I used xargs instead of the unquoted array split the finding suggested. Upstream pasted the expression straight into the script, so the shell honored quotes in it, and the default value (-name 'stack*.yaml') relies on that. Replaced the fixed EOM heredoc delimiter with a new random one from /dev/urandom on each run. This re-applies the previous harden's fix, adding xargs -r, the shell's built-in printf, and the unmatched-quote check.

