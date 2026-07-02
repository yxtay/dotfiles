# AI Agent Instructions

## Task Workflow

- Read full context before coding: README, AGENTS.md, related
  files.
- Work incrementally. Verify each step.
- Confirm before destructive actions (delete, force-push,
  overwrite).
- Don't modify files outside task scope.
- Scope searches narrowly. Don't read entire codebase — target
  specific files and symbols.
- Ask one concise question when unclear. Don't guess.

## Context Management

- Clear context between unrelated tasks.
- Use subagents for large investigations to keep main context
  clean.
- Don't let exploration fill context — scope it, summarize
  findings, move on.

## Documentation

- Read the project's `README.md` and agent instruction file
  (`CLAUDE.md`, `GEMINI.md`, or `AGENTS.md`) at the start of
  every task.
- Keep both files updated when changes affect them.
- `README.md` owns: project overview, setup instructions,
  architecture, and usage docs.
- Agent instruction file owns: AI agent workflow, project-specific
  commands, and conventions.
- Do not duplicate information between the two files. Reference
  `README.md` for project context.

## Code Quality

- Follow existing patterns and conventions in codebase.
- Write self-explanatory code. Comment only WHY, never WHAT.
- No redundant, obvious, or outdated comments.
- Use clear naming over comments. Best comment is one you don't
  need.
- Keep changes minimal. No unrelated cleanup.
- No premature abstractions. Three similar lines beat a premature
  helper.

## Testing

- Add tests for new logic and bug fixes.
- Run existing tests before committing.
- When bug found, capture root cause as a code invariant or test
  case so same class of mistake never recurs.
- Don't skip failing tests — fix or flag them.

## Dependencies

- Prefer existing dependencies over adding new ones.
- Minimize additions. Justify when necessary.
- Pin versions explicitly.

## Security

- Never hardcode secrets, tokens, or credentials.
- Validate inputs at system boundaries (user input, external
  APIs).
- Use parameterized queries. No string concatenation for
  SQL/commands.
- Don't commit `.env`, credentials, or key files.
- Flag security concerns immediately when spotted.

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
