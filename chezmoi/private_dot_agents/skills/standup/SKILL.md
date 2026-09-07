---
name: standup
description: Standup digest from agentmemory sessions + atuin, grouped by repo. Supports date ranges and project filters.
disable-model-invocation: true
argument-hint: "[<date-or-range>] [--project <pattern>]"
---

# Standup

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

1. **Resolve dates** — produce `start = <start-date>T00:00:00Z` and `end = <end-date>T23:59:59Z`.

2. **Load sessions** — fetch and reduce to standup fields only. Use
   `dangerouslyDisableSandbox: true` (sandbox blocks localhost TCP):

   ```sh
   curl -s "http://localhost:3111/agentmemory/sessions" \
     | jq '[.sessions[]
         | select(.observationCount > 0)
         | select(.startedAt >= "<start>" and .startedAt <= "<end>")
         | {id,
            cwd,
            narrative: .summary.narrative}]'
   ```

   If the request fails or returns `[]`, output: "No agentmemory sessions found for `<range>`."

3. **Fallback for sparse summaries** — for any session where `narrative` is null/empty,
   fetch raw observations (use `dangerouslyDisableSandbox: true`):

   ```sh
   curl -s "http://localhost:3111/agentmemory/observations?sessionId=<id>" \
     | jq '[.observations[] | {type, narrative}]'
   ```

   Observation schema: `type` is `"command_run"` or `"conversation"`. `narrative` is the raw payload:

   - `"conversation"` — plain user message text; use directly to infer intent.
   - `"command_run"` — JSON blob `{command,...} | {stdout,stderr,...}`; grep for
     `git`, file paths, and tool names to infer tasks.

   Prefer `"conversation"` observations for intent; use `"command_run"` to confirm concrete actions.

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

5. **Load GitLab MRs** — skip entire step if `glab` is not installed. For each unique `cwd`
   from sessions, run both queries (each may fail silently — wrap in `2>/dev/null || true`):

   ```sh
   # MRs authored by me
   cd "<cwd>" && glab mr list --author=@me --state=all \
     --created-after="<start-date>" --created-before="<end-date>" \
     --output json 2>/dev/null \
     | jq '[.[] | {iid, title, web_url, state, role: "author"}]'

   # MRs approved by me — requires user ID
   me_id=$(cd "<cwd>" && glab api /user 2>/dev/null | jq -r '.id')
   cd "<cwd>" && glab api /merge_requests \
     -f "approved_by_ids[]=$me_id" \
     -f state=merged \
     -f created_after="<start>" \
     -f created_before="<end>" 2>/dev/null \
     | jq '[.[] | {iid, title: .title, web_url, state, role: "approved"}]'
   ```

   Deduplicate by `iid` across both result sets (an authored MR may also appear in approved).
   Group results by `cwd` for use in synthesis.

6. **Synthesize** — group all sessions by `cwd`. For each repo, read all narratives as a
   single body and extract every distinct concrete task or change. Shell history fills gaps;
   narratives supply intent. MR data from step 5 adds concrete merge/review activity.
   One bullet per logical task, deduplicated across all sources.

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
