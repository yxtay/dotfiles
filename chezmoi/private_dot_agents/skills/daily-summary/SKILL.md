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

2. **Load memory** — read `~/.memsearch/memory/<date>.md`. Note if missing
   (continue with shell history only; don't stop).

3. **Load shell history** — run:

   ```sh
   atuin search --after "<date> 00:00:00" --before "<date+1> 00:00:00" \
     --format "{time} {directory} {command}" --limit 2000 2>/dev/null
   ```

   Filter to meaningful commands only:
   - **Keep**: git, brew, gh, ssh, docker, uv, npx, databricks, aws, az, claude,
     pre-commit, chezmoi, and any command with substantive args (file paths, flags)
   - **Drop**: bare navigational/inspection commands (ls, cat, cd, echo, pwd,
     which, man, history, atuin with no args)
   - **Deduplicate**: collapse repeated identical or near-identical commands
     (e.g. multiple `az login` variants → one entry noting it was attempted);
     keep only the last successful variant when a command was retried

4. **Merge** — combine memory log tasks with shell history signals. Shell
   history fills gaps when memory is missing; memory provides intent/context
   that raw commands lack. Deduplicate: one bullet per logical task regardless
   of source.

5. **Map** — assign each task to the repo/dir where the change happened. Tasks
   with no repo go under `Other`.

6. **Output** the standup in a fenced code block. No preamble. One bullet per
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
