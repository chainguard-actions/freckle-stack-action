<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action--generate-matrix/v5.7.32

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action--generate-matrix/v5.7.32** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) violation: the expression ${{ inputs.find-options }} is placed directly in the run: script of the 'generate' step: `find ${{ inputs.find-options }} -printf '"%f"\n' | sort -V | jq --slurp`. The value is pasted into the bash script before the shell runs, so a caller can inject shell metacharacters such as `; curl ... | sh` or `$(...)`. Fix: pass the input through an env: variable (e.g. FIND_OPTIONS) and expand it as a shellcheck-annotated array (e.g. `# shellcheck disable=SC2206` then `opts=(${FIND_OPTIONS})`, `find "${opts[@]}" ...`). Note that the default value contains quotes, which an array expansion does not interpret, so the default may need adjusting.

Locations:

- `action.yml:26`

### github-env-injection (severity: high)

Multi-line write to $GITHUB_OUTPUT uses a fixed heredoc delimiter: `echo 'stack-yamls<<EOM'` ... `echo 'EOM'`. The value in between is the output of a find command whose options and file names are controlled by the caller (inputs.find-options, inputs.working-directory). If a file name or output line equals 'EOM', the block ends early and the lines after it become new key=value output entries. Fix: build the delimiter from a secure random source on every run, e.g. EOF="EOF_$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')".

Locations:

- `action.yml:25`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.find-options }}" appears directly in run: block of step "Generate"; move to env: map

Locations:

- `action.yml:26`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed action.yml without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/generate-matrix/action.yml b/generate-matrix/action.yml
index fd7eb39..208e340 100644
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
+        EOF="EOF_$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')"
         {
-          echo 'stack-yamls<<EOM'
-          find ${{ inputs.find-options }} -printf '"%f"\n' | sort -V | jq --slurp
-          echo 'EOM'
+          echo "stack-yamls<<$EOF"
+          find "${find_args[@]}" -printf '"%f"\n' | sort -V | jq --slurp
+          echo "$EOF"
         } >>"$GITHUB_OUTPUT"

```

Locations:

- `action.yml`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection, prior-fix

**Notes:**

Moved inputs.find-options into env FIND_OPTIONS, tokenized quote-aware via guarded xargs (matching upstream's inline-expression semantics, so the default "-name 'stack*.yaml'" still works), and replaced the fixed EOM heredoc delimiter with a random one from /dev/urandom. Re-applied the previous harden patch.

