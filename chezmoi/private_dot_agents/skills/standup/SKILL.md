---
name: standup
description: Standup digest from agentmemory sessions + atuin, grouped by repo. Args: [date-or-range] [--project pattern]
disable-model-invocation: true
argument-hint: "[<date-or-range>] [--project <pattern>]"
---

# Standup

Produce a standup from agentmemory session history for the requested date or date range,
optionally filtered to a project pattern.

## Argument parsing

Parse `$ARGUMENTS` (order-independent):

- **Date / range**:
  - `YYYY-MM-DD` — single date
  - `YYYY-MM-DD:YYYY-MM-DD` — inclusive range
  - `past N days/weeks`, `last week`, `this sprint`, `past sprint` — resolve relative to today
  - Default (no date arg): yesterday
- **Project filter**: `--project <pattern>` or `-p <pattern>` —
  case-insensitive substring matched against `cwd`.

## Steps

1. **Resolve dates** — produce `start = <start-date>T00:00:00Z` and `end = <end-date>T23:59:59Z`.

2. **Load sessions** — fetch and reduce to standup fields only:

   ```sh
   curl -s "http://localhost:3111/agentmemory/sessions?since=<start>&until=<end>" \
     | jq '[.sessions[]
         | select(.observationCount > 0)
         | {cwd,
            title: .summary.title,
            narrative: .summary.narrative,
            keyDecisions: .summary.keyDecisions,
            filesModified: .summary.filesModified,
            concepts: .summary.concepts}]'
   ```

   If the request fails or returns `[]`, output: "No agentmemory sessions found for `<range>`."

3. **Load shell history** — run:

   ```sh
   atuin search --after "<start-date> 00:00:00" --before "<end-date> 23:59:59" \
     --format "{time} {directory} {command}" --limit 5000 2>/dev/null
   ```

   Keep: `git`, `brew`, `gh`, `ssh`, `docker`, `uv`, `npx`, `databricks`, `aws`, `az`,
   `claude`, `pre-commit`, `chezmoi`, and any command with file paths or flags.
   Drop: bare `ls`, `cat`, `cd`, `echo`, `pwd`, `which`, `man`, `history`.
   Deduplicate: one entry per logical action, last successful variant when retried.

4. **Extract tasks** — for each session: repo/dir = `cwd`; derive tasks in priority order:
   1. `title` — top-level bullet
   2. `keyDecisions` — concrete decisions, use as sub-bullets
   3. `narrative` — synthesize to fill gaps keyDecisions leaves
   4. `filesModified` — sub-bullets when keyDecisions absent
   5. `concepts` — thematic fallback when all above absent

5. **Merge** — combine session tasks with shell history. Shell fills gaps;
   session summaries supply intent. One bullet per logical task, deduplicated across sources.

6. **Filter** — apply `--project`: drop repos whose path doesn't contain the pattern.
   Drop `Other` bucket when filter is active.

7. **Output** — fenced code block, no preamble. One bullet per task ≤12 words.
   Nest sub-tasks one level deep only when genuinely distinct. Skip exploration-only sessions.

````text
```
- `<repo-path>`
  - <task>
    - <sub-task if distinct>
- `<repo-path-2>`
  - <task>
- Other                ← omitted when --project filter active
  - <task not tied to a repo>
```
````
