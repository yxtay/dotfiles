---
name: daily-summary
description: Daily standup digest from memsearch activity logs, grouped by repo.
disable-model-invocation: true
argument-hint: "[YYYY-MM-DD]"
---

# Daily Summary

Produce a **standup** from the memsearch memory log for the requested date.

## Steps

1. **Date** — use `$ARGUMENTS` if non-empty; default to yesterday. Validate
   `YYYY-MM-DD`; reject with an error message on malformed input.

2. **Load** — read `~/.memsearch/memory/<date>.md`. Stop and tell the user if the file is missing.

3. **Map** — assign each task to the repo where the change happened. Tasks
   with no repo go under `Other`.

4. **Output** the standup in a fenced code block. No preamble. One bullet per
   task, ≤12 words. Under each task, nest sub-tasks one level deep only when
   they are genuinely distinct steps, not elaborations. Skip sessions with only
   exploration and no resulting change or decision.

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
