<!-- markdownlint-disable -->

# Hardening Report: freckle--stack-action/v5.7.31

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **freckle--stack-action/v5.7.31** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

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

**Notes:**

Not fixed: example/stack-link.yaml is still a symlink to ./stack.yaml. The prior harden replaced it with a regular file containing 'resolver: lts-18.3'. I wrote that content to the path, but the listing afterwards still showed the symlink. The write most likely went through the link into example/stack.yaml, which already had the same content, so nothing changed. None of the available tools can delete a file or replace a symlink. To finish it, remove the link and commit a regular file with the content 'resolver: lts-18.3\n'.

