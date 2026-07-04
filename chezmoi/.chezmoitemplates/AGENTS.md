# AI Agent Instructions

## Task Workflow

- Read README and related files before coding.
- Confirm before destructive actions (delete, force-push,
  overwrite).
- Scope searches narrowly. Don't read entire codebase — target
  specific files and symbols.
- Ask one concise question when unclear. Don't guess.

## Context Management

- Clear context between unrelated tasks.
- Delegate to subagents when a task risks large context pollution —
  broad searches, multi-file investigations, log/output analysis,
  or reading many files to extract a small answer. Return only the
  conclusion to the main thread.
- Don't let exploration fill context — scope it, summarize
  findings, move on.

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
