---
name: code-review-policy
description: >
  Policy for reviewing code changes: severity levels, what to check, and when a
  change may merge. Use when reviewing a PR, diff, or file, or deciding whether
  work is ready to merge. For the comment wording/format, see caveman-review.
---

# Code Review Policy

Review code changes against this policy. For the terse comment format itself,
use the caveman-review skill.

## Severity levels

- **critical** — blocks merge.
- **high** — blocks merge.
- **medium** — non-blocking.
- **low** — non-blocking.

## What to check

- Correctness, security, tests, performance.
- Be specific: reference file paths and line numbers.
- Suggest fixes, not just problems.

## Merge gate

- Approve only when all critical and high items are resolved.
- Run tests locally before approving.
