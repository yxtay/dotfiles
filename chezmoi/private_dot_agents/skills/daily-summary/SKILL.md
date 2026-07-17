---
name: daily-summary
description: Daily standup digest from memsearch activity logs, grouped by repo.
disable-model-invocation: true
argument-hint: "[YYYY-MM-DD]"
---

# Daily Summary

Produce a **standup** — a repo-grouped bullet digest of the day's work — from
the memsearch memory log for the requested date.

## Steps

1. **Date** — use `$ARGUMENTS` if provided and non-empty; treat absent or
   empty as omitted and default to yesterday. Validate the value is a
   calendar-valid `YYYY-MM-DD`. Reject and report any malformed input before
   proceeding.

2. **Load** — read `~/.memsearch/memory/<date>.md`. Stop and tell the user if the file is missing.

3. **Map** — identify every repo mentioned; assign each task to the repo where
   the code change happened. Tasks not tied to any specific repo go under
   `Other`. Done when every distinct repo is identified and every substantive
   task is assigned.

4. **Output** the standup in a fenced code block. No preamble. One bullet per
   distinct task. Each bullet ≤12 words. Under each task, nest sub-tasks one
   level deep only when they are genuinely distinct steps of the parent, not
   just elaborations. Skip sessions where all entries are reads, searches, or
   investigations with no resulting change or decision.

````text
```
- `<repo-path>`
  - <task>
    - <sub-task if distinct>
  - <task>
- `<repo-path-2>`
  - <task>
- Other
  - <task not tied to a repo>
```
````
