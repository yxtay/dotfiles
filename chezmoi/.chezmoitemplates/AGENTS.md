# AI Agent Instructions

## Task Workflow

- Autonomy scales with reversibility: read freely; edit
  autonomously if reversible; confirm before force-push or delete.
- Stop and ask only when: multiple valid approaches exist, code
  would be deleted or restructured, or the request is ambiguous.
- Push back on bad ideas with reasoning. Don't agree just to be
  agreeable.

## Documentation

- Read the project's `README.md` at the start of every task.
- Keep it and the agent instruction file updated when changes
  affect them.
- `README.md` owns: project overview, setup instructions,
  architecture, and usage docs.
- Agent instruction file owns: AI agent workflow, project-specific
  commands, and conventions.
- Do not duplicate information between the two files. Reference
  `README.md` for project context.

## Knowledge Management

Durable knowledge lives under `~/wiki/`, as an Open Knowledge Format
(OKF) bundle. Use the `okf` skill for the format and bundle-
maintenance conventions.

- **Read**: at session start, read `~/wiki/index.md`; load topic
  files only when relevant.
- **Write**: when a task surfaces a durable fact, decision, or
  gotcha likely to recur, write it to the matching concept file
  immediately — don't wait to be asked or batch it for session end.
- **Search before writing**: check whether an existing concept
  already covers the topic; amend it in place rather than creating
  a near-duplicate. Only create a new concept file for a genuinely
  new topic.
- **Organize** by topic freely, no fixed taxonomy. Split files that
  grow unwieldy or unfocused.
- **Maintain as you go**: when editing a topic file, fix or remove
  entries you find stale, wrong, or superseded. Keep `index.md` in
  sync with what actually exists on disk, and add a `log.md` entry
  at that directory level if one exists.
- **Sweep periodically**: don't rely only on the reactive rule
  above — occasionally scan concept files you haven't touched for
  staleness against current code/decisions.
- `~/.memsearch/USER.md` is a related, read-only reference
  maintained by memsearch — don't edit it or merge it into
  `~/wiki/`.

## Context Management

- Scope searches narrowly. Don't read entire codebase — target
  specific files and symbols. Don't let exploration fill context —
  scope it, summarize findings, move on.
- Delegate tool calls that pull raw content into context —
  WebSearch, WebFetch, Read, Grep, bash output/logs, LSP
  reference/symbol lookups, MCP tool results — to a subagent
  unless the raw output is needed verbatim. Tell the subagent
  exactly what information to return; it should reply with only
  that summary or extracted answer, never the full raw output.
  Default to a lighter model (e.g. haiku) unless the task needs
  deeper reasoning.
- Skip delegation for small, targeted reads (e.g. a file you're
  about to edit, a grep with an already-known match), or when a
  subagent's result was wrong or incomplete and fixing it would
  need repeated round-trips — handle those directly.
- If a subagent needs the full prior conversation (not a fresh
  scoped task) but its own tool noise still shouldn't return to the
  parent, use a fork instead of a plain subagent.

## Engineering Practice

- Before writing new code, check for existing reusable code or an
  extractable abstraction. If duplicating significant logic, extract
  instead.
- A manual task done twice is technical debt — script it, with
  help text, before a third.

## Git Workflow

- Work in a feature branch, not the default branch.
- Branch naming: `<type>/<short-description>` (e.g.,
  `feat/add-auth`, `fix/login-redirect`).
- Make commits regularly as you progress — don't accumulate large
  uncommitted changes.
- Follow [Conventional Commits](https://www.conventionalcommits.org/);
  for message rules see the caveman-commit skill.
- Push the feature branch regularly so work isn't lost.
