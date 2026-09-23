---
name: update-summary
description: Standup digest from agentmemory sessions + atuin + GitLab MRs, grouped by repo. Supports date ranges and project filters.
disable-model-invocation: true
argument-hint: "[<date-or-range>] [--project <pattern>]"
---

# Update Summary

## Argument parsing

Parse `$ARGUMENTS` (order-independent):

- **Date / range**:
  - `YYYY-MM-DD` — single date
  - `YYYY-MM-DD:YYYY-MM-DD` — inclusive ISO range
  - `past N days/weeks`, `last week` — relative natural language; resolve against yesterday's date
  - `this sprint` / `past sprint` — 2-week window ending yesterday / ending 14 days ago
  - Default (no date arg): yesterday
  - Reject with an error if end < start or the expression is unrecognisable.
- **Project filter**: `--project <pattern>` or `-p <pattern>` —
  case-insensitive substring matched against `cwd`.

## Steps

Execution order: `[1 ‖ 2] → [3 ‖ 4 ‖ 5] → 6 → 7`

**Chunking**: if the range spans more than 7 days, split into weekly sub-ranges and run
`[3 ‖ 4 ‖ 5] → 6` independently for each week, then merge all per-week syntheses before step 7.
For ranges ≤ 7 days, process in a single pass.

1. **Resolve dates** — interpret dates in the local timezone. Get the offset with:

   ```sh
   date +%z   # e.g. +0800
   ```

   Then produce UTC equivalents for midnight-to-midnight of the resolved date(s):
   `start = <start-date>T00:00:00<offset>` converted to UTC
   `end   = <end-date>T23:59:59<offset>` converted to UTC
   Use these UTC values in all subsequent queries.

2. **Start agentmemory** (`dangerouslyDisableSandbox: true` — sandbox blocks localhost TCP):

   ```sh
   bash "$HOME/.claude/skills/update-summary/hooks/start-agentmemory.sh"
   ```

   If it exits non-zero or agentmemory is still unreachable, report:
   `"agentmemory failed to start. Check ~/.agentmemory/server.log or run: npx @agentmemory/agentmemory"`
   and stop.

3. **Load sessions** (`dangerouslyDisableSandbox: true` — sandbox blocks localhost TCP):

   ```sh
   curl -s --max-time 30 "http://localhost:3111/agentmemory/sessions" \
     | jq '[.sessions[]
         | select(.observationCount > 0)
         | select(.startedAt >= "<start>" and .startedAt <= "<end>")
         | {id, cwd, startedAt, narrative: .summary.narrative, keyDecisions: .summary.keyDecisions}]'
   ```

   If the request fails or returns `[]`, note "No agentmemory sessions found for `<range>`"
   and continue.

4. **Load shell history** — run:

   ```sh
   atuin search --after "<start>" --before "<end>" \
     --format "{time} {directory} {command}" --limit 5000 2>/dev/null
   ```

   - **Keep**: `git`, `brew`, `gh`, `ssh`, `docker`, `uv`, `npx`, `databricks`, `aws`, `az`,
     `claude`, `pre-commit`, `chezmoi`, and any command with file paths or flags.
   - **Drop**: bare `ls`, `cat`, `cd`, `echo`, `pwd`, `which`, `man`, `history`, `atuin` with no args.
   - **Deduplicate**: collapse repeated identical or near-identical commands; keep only the last
     successful variant when a command was retried.

5. **Load GitLab MRs** — skip entire step if `glab` is not installed. Use the pinned
   hostname `sgts.gitlab-dedicated.com`. Run two global queries (no cwd needed):

   ```sh
   # Note: -f flags force POST (404); embed params in URL for GET.
   # MRs authored by me
   HOST=sgts.gitlab-dedicated.com
   glab api --hostname "$HOST" \
     "/merge_requests?scope=created_by_me&state=all&created_after=<start>&created_before=<end>" \
     2>/dev/null \
     | jq '[.[] | {iid, title, web_url, project_path: .references.full, state, role: "author"}]'

   # MRs approved by me
   me_id=$(glab api --hostname "$HOST" /user 2>/dev/null | jq -r '.id')
   q="approved_by_ids[]=$me_id&state=merged&created_after=<start>&created_before=<end>"
   glab api --hostname "$HOST" "/merge_requests?$q" 2>/dev/null \
     | jq '[.[] | {iid, title, web_url, project_path: .references.full, state, role: "approved"}]'
   ```

   Deduplicate by `(host, iid, project_path)`. Use `project_path` to match MRs to session `cwd`s
   during synthesis; unmatched MRs go under `Other`.

6. **Synthesize** — sessions are returned in chronological order. Group by `cwd` yourself during
   synthesis; preserve that chronological order within each group. Extract every distinct concrete
   task or change per repo. Shell history fills gaps; narratives supply intent. MR data from step 5
   adds concrete merge/review activity. One bullet per logical task, deduplicated across all sources.

7. **Output** — fenced code block only. One bullet per task ≤12 words.
   Nest sub-tasks one level deep only when genuinely distinct. Skip exploration-only sessions.
   Aggregate all tasks across the entire date range — do not split or label by date.
   Apply `--project` filter: drop repos whose path doesn't contain the pattern;
   omit `Other` when filter is active.

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
