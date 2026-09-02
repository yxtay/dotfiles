---
name: standup
description: Standup digest from agentmemory sessions + atuin, grouped by repo. Args: [date-or-range] [--project pattern]
disable-model-invocation: true
argument-hint: "[<date-or-range>] [--project <pattern>]"
---

# Standup

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

   Keep: `git`, `brew`, `gh`, `ssh`, `docker`, `uv`, `npx`, `databricks`, `aws`, `az`,
   `claude`, `pre-commit`, `chezmoi`, and any command with file paths or flags.
   Drop: bare `ls`, `cat`, `cd`, `echo`, `pwd`, `which`, `man`, `history`.
   Deduplicate: one entry per logical action, last successful variant when retried.

5. **Synthesize** — group all sessions by `cwd`. For each repo, read all narratives as a
   single body and extract every distinct concrete task or change. Shell history fills gaps;
   narratives supply intent. One bullet per logical task, deduplicated across both sources.

6. **Output** — fenced code block, no preamble. One bullet per task ≤12 words.
   Nest sub-tasks one level deep only when genuinely distinct. Skip exploration-only sessions.
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
