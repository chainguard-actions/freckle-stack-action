<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action--generate-matrix/v5.7.33

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action--generate-matrix/v5.7.33** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) violated: the expression ${{ inputs.find-options }} is placed directly inside the run: script of step 'generate'. The offending line is `find ${{ inputs.find-options }} -printf '"%f"\n' | sort -V | jq --slurp`. The input is pasted into the script before bash runs it, so a caller can add shell metacharacters (;, $(...), backticks) or find's own -exec to run any command. Fix: pass the input through env (e.g. FIND_OPTIONS: ${{ inputs.find-options }}) and split it into an array, e.g. `# shellcheck disable=SC2206` followed by `opts=($FIND_OPTIONS)`, then call `find "${opts[@]}" ...`.

Locations:

- `action.yml:25`

### github-env-injection (severity: high)

Step 'generate' writes a multi-line value to $GITHUB_OUTPUT between the fixed heredoc delimiter 'EOM' (`echo 'stack-yamls<<EOM'` ... `echo 'EOM'`). The value comes from running find with the untrusted inputs.find-options, which can be injected. If the value contains a line equal to the delimiter, the block ends early and extra outputs are added. Fix: generate the delimiter from a secure random source each run, e.g. EOF="EOF_$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')".

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
index fd7eb39..fa6b8f8 100644
--- a/generate-matrix/action.yml
+++ b/generate-matrix/action.yml
@@ -16,13 +16,39 @@ outputs:
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
+          printf '%s' "$FIND_OPTIONS" | xargs -r true >/dev/null   # fails on an unmatched quote
+          while IFS= read -r -d '' t; do find_args+=("$t"); done \
+            < <(printf '%s' "$FIND_OPTIONS" | xargs -r sh -c 'printf "%s\0" "$@"' sh)
+        fi
+        EOM="EOF_$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')"
         {
-          echo 'stack-yamls<<EOM'
-          find ${{ inputs.find-options }} -printf '"%f"\n' | sort -V | jq --slurp
-          echo 'EOM'
+          echo "stack-yamls<<$EOM"
+          find "${find_args[@]}" -printf '"%f"\n' | sort -V | jq --slurp
+          echo "$EOM"
         } >>"$GITHUB_OUTPUT"

```

Locations:

- `action.yml`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection, prior-fix

**Notes:**

Moved inputs.find-options into env FIND_OPTIONS. It is now split into a bash array with the quote-aware xargs method, because upstream pasted the expression straight into the script and its default value contains quotes ('stack*.yaml'). A guard makes the step fail on an unmatched quote. The fixed 'EOM' heredoc delimiter was replaced with one generated from /dev/urandom on each run. The multi-line output value is written unchanged. This puts back the previous harden's patch.

