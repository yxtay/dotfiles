---
name: daily-summary
description: Daily standup digest from memsearch activity logs, grouped by repo.
disable-model-invocation: true
argument-hint: "<YYYY-MM-DD>"
---

# Daily Summary

Produce a **standup** — a repo-grouped bullet digest of the day's work — from
the memsearch memory log for the requested date.

## Steps

1. **Date** — use `args` (format `YYYY-MM-DD`); default to yesterday if omitted.

2. **Load** — read `~/.memsearch/memory/<date>.md`. Stop and tell the user if the file is missing.

3. **Map** — identify every repo mentioned; assign each task to the repo where
   the code change happened. Done when every distinct repo is identified and
   every substantive task is assigned.

4. **Output** the standup in a fenced code block. No preamble. One bullet per
   distinct task. Each bullet ≤10 words. Nest sub-tasks only when they are
   genuinely distinct steps of the parent, not just elaborations. Max 2 levels.
   Skip sessions with no substantive outcome.

````text
```
- `<repo-path>`
  - <task>
    - <sub-task if distinct>
  - <task>
- `<repo-path-2>`
  - <task>
```
````
