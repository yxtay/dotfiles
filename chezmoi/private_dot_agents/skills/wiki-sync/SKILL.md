---
name: wiki-sync
description: >-
  Synthesize agentmemory Obsidian export into ~/wiki/ OKF bundle. Reads from
  ~/.agentmemory/obsidian_export/ (auto-populated by OBSIDIAN_AUTO_EXPORT=true).
  Use when you want to promote durable knowledge from agent sessions into the wiki.
argument-hint: "[--date <YYYY-MM-DD>]"
---

# Wiki Sync

Read agentmemory's Obsidian export and merge durable knowledge into `~/wiki/`
following OKF conventions (via the `okf` skill).

Export path: `~/.agentmemory/obsidian_export/` — populated automatically on
every consolidation when `OBSIDIAN_AUTO_EXPORT=true`.

## Arguments

- `--date <YYYY-MM-DD>` / `-d <YYYY-MM-DD>` — only include files modified on or
  after this date. Resolved via `-mtime` on the export files. Default: no filter
  (all files).

## Steps

1. **Check export exists** — verify `~/.agentmemory/obsidian_export/` has content:

   ```sh
   ls ~/.agentmemory/obsidian_export/memories/ 2>/dev/null \
     || ls ~/.agentmemory/obsidian_export/lessons/ 2>/dev/null
   ```

   If empty or missing: output "No export content yet — consolidation hasn't run.
   Trigger manually: `POST /agentmemory/consolidate`" and stop.

2. **Read sources** — collect all `.md` files under `~/.agentmemory/obsidian_export/`.
   If `--date` given, restrict to files modified on or after that date:

   ```sh
   find ~/.agentmemory/obsidian_export -name "*.md" -newer /tmp/wiki-sync-date-ref
   # create reference file: touch -t <YYYYMMDDHHMMSS> /tmp/wiki-sync-date-ref
   ```

   Each file has YAML frontmatter with `type`, `concepts`, `importance`, etc.
   Skip `MOC.md`. For memories, skip entries where `importance < 8`.

3. **Load wiki** — read `~/wiki/index.md`. Map existing topic names to concept
   file paths.

4. **Group by topic** — cluster findings by `concepts` frontmatter. Match to
   existing wiki topic names where obvious. Unmatched findings with ≥2 items on
   the same concept form a new topic. Singletons with no clear home: skip.

5. **Merge into wiki** — use OKF `maintain` for existing concepts, `produce` for
   new ones:

   - **Existing concept**: read the file, append new facts/rules under the most
     relevant heading. Update `timestamp` in frontmatter. Don't duplicate.
   - **New concept**: create from OKF template. Required frontmatter:
     `type`, `title`, `description`, `tags` (from `concepts`), `timestamp` (ISO 8601).
     Body: structural markdown (tables, lists) over prose. Add `# Related` section.
   - Hard OKF rules: non-empty `type` in every file; one concept per file;
     never name a concept file `index.md` or `log.md`.

6. **Update index and log**:

   - `~/wiki/index.md`: add entries for any new concept files.
   - `~/wiki/log.md` (if it exists): prepend ISO date + bullet per concept touched.

## Source field mapping

| Source  | Frontmatter field | Wiki usage                         |
|---------|-------------------|------------------------------------|
| lesson  | `body`            | Rule/gotcha under relevant heading |
| lesson  | `concepts`        | `tags` + cross-link hints          |
| crystal | `content`         | Fact under relevant heading        |
| memory  | `content`         | Supporting detail                  |
| memory  | `concepts`        | Tags and cross-link hints          |
