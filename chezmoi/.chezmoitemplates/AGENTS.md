# AI Agent Instructions

## Task Workflow

- Confirm before destructive actions (delete, force-push,
  overwrite).
- Ask one concise question when unclear. Don't guess.

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

## Documentation

- Read the project's `README.md` and agent instruction file
  (`CLAUDE.md` or `AGENTS.md`) at the start of every task.
- Keep both files updated when changes affect them.
- `README.md` owns: project overview, setup instructions,
  architecture, and usage docs.
- Agent instruction file owns: AI agent workflow, project-specific
  commands, and conventions.
- Do not duplicate information between the two files. Reference
  `README.md` for project context.

## Global Knowledge

Durable knowledge lives under `~/.okf/`, as an Open Knowledge Format
(OKF) bundle. Use the `okf` skill for the format and bundle-
maintenance conventions.

Rules:

- At session start, read `~/.okf/index.md`; load topic files
  only when relevant.
- Organize by topic freely, no fixed taxonomy. Split files that
  grow unwieldy or unfocused.
- Maintain as you go: when editing a topic file, fix or remove
  entries you find stale, wrong, or superseded. Keep `index.md` in
  sync with what actually exists on disk.
- `~/.memsearch/USER.md` is a related, read-only reference
  maintained by memsearch — don't edit it or merge it into
  `~/.okf/`.

## Code Quality

- Follow existing patterns and conventions in codebase.
- No premature abstractions. Three similar lines beat a premature
  helper.

## Testing

- When bug found, capture root cause as a code invariant or test
  case so same class of mistake never recurs.
- Don't skip failing tests — fix or flag them.

## Git Workflow

- Work in a feature branch, not the default branch.
- Branch naming: `<type>/<short-description>` (e.g.,
  `feat/add-auth`, `fix/login-redirect`).
- Run project formatter before committing.
- Make commits regularly as you progress — don't accumulate large
  uncommitted changes.
- Follow [Conventional Commits](https://www.conventionalcommits.org/);
  for message rules see the caveman-commit skill.
- Push the feature branch regularly so work isn't lost.
- When task complete, open a pull request against the default
  branch.
