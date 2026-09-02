---
name: update-summary
description: Standup digest from activity logs, grouped by repo. Supports date ranges and project filters.
disable-model-invocation: true
argument-hint: "[<date-or-range>] [--project <pattern>]"
---

# Update Summary

## Argument parsing

Parse `$ARGUMENTS` (order-independent):

- **Date / range**:
  - `YYYY-MM-DD` — single date
  - `YYYY-MM-DD:YYYY-MM-DD` — inclusive ISO range
  - `past 2 weeks`, `last week`, `past 5 days` — relative natural language; resolve
    against yesterday's date to produce a concrete start and end date
  - `this sprint` / `past sprint` — treat as 2-week window ending yesterday / ending 14 days ago
  - Default (no date arg): yesterday
  - Reject with an error if end < start or the expression is unrecognisable.
- **Project filter**: `--project <pattern>` (or `-p <pattern>`) — case-insensitive
  substring matched against the repo/directory path. Example: `--project aiap`.

Examples:

- `/update-summary` → yesterday, all projects
- `/update-summary 2026-07-20` → single date, all projects
- `/update-summary 2026-07-07:2026-07-20` → range, all projects
- `/update-summary past 2 weeks --project aiap` → last 14 days, AIAP projects only
- `/update-summary last week` → Mon–Sun of last calendar week, all projects

## Steps

1. **Resolve dates** — expand the range into an ordered list of calendar dates
   (start…end inclusive). For a single date, the list has one entry.

2. **Load memory** — for each date in the list, read `~/.memsearch/memory/<date>.md`.
   Silently skip missing files. Concatenate all loaded content in chronological order.

3. **Load shell history** — run a single atuin query spanning the full range:

   ```sh
   atuin search --after "<start-date> 00:00:00" --before "<end-date> 23:59:59" \
     --format "{time} {directory} {command}" --limit 5000 2>/dev/null
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

6. **Output** — fenced code block only. One bullet per task ≤12 words.
   Nest sub-tasks one level deep only when genuinely distinct. Skip exploration-only sessions.
   Aggregate all tasks across the entire date range — do not split or label by date.
   Apply `--project` filter: drop repos whose path doesn't contain the pattern;
   omit `Other` when filter is active.

````text
```
- `<repo-path>`
  - <task>
    - <sub-task if distinct>
  - <task>
- `<repo-path-2>`
  - <task>
- Other                ← omitted when --project filter is active
  - <task not tied to a repo>
```
````
