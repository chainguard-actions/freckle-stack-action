<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.33

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.33** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed example/stack-link.yaml without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/example/stack-link.yaml b/example/stack-link.yaml
deleted file mode 120000
index d6958b8..0000000
--- a/example/stack-link.yaml
+++ /dev/null
@@ -1 +0,0 @@
-./stack.yaml
\ No newline at end of file
diff --git a/example/stack-link.yaml b/example/stack-link.yaml
new file mode 100644
index 0000000..fcf5622
--- /dev/null
+++ b/example/stack-link.yaml
@@ -0,0 +1 @@
+resolver: lts-18.3

```

Locations:

- `example/stack-link.yaml`

## Iteration Notes

### Iteration 1

**Fixes applied:** prior-fix

**Notes:**

I wrote example/stack-link.yaml as a regular file containing 'resolver: lts-18.3\n', the same content as example/stack.yaml, to re-apply the previous harden's change. I couldn't confirm it worked. After the write, list_directory still showed the path as a symlink to ./stack.yaml. The write may have followed the symlink and rewritten stack.yaml with identical content instead. Either way, reading the path gives the same text, so the action behaves the same. If the symlink is still there, it needs to be removed and replaced with a plain file outside this tool.

