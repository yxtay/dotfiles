---
name: lean-ctx
description: Compress large Bash/file/grep output before it enters context. Use when command output > ~500 lines, file reads > ~200 lines, grep spanning many files, or user says "use lean-ctx".
---

# lean-ctx

```bash
lean-ctx -c "<command>"        # shell command, compressed
lean-ctx read <file>            # file, compressed
lean-ctx grep <pattern> [path]  # search, compressed
lean-ctx raw "<command>"        # uncompressed escape hatch
```

Route through lean-ctx when output is large. Use Read/Bash/Grep directly when output is
small or needed verbatim (diffs, exact error strings, structured data to parse).
