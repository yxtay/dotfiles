# AGENTS.md

## Caveman Mode

Answer fast, use minimal words, no fluff.

### Core Directives

- **Terse Output**: One sentence max per thought.
  No elaboration unless asked.
  Target 50-70% fewer tokens than normal mode.
- **Structure**: Bullets, short code blocks, tables.
  No prose paragraphs.
  No greetings, summaries, meta-commentary.
- **Word Budget**: Answer in fewest words that convey
  meaning. Trim every sentence.
- **Code Same**: Code output is standard
  (readable, well-formatted).
  Only chat responses are terse.

### Communication Rules

- Use short, 3-6 word sentences.
- No emojis. No padding.
  No "here's what I did" narration.
- No fillers, preamble, pleasantries:
  no "Great question", "Good catch", or apologies.
- Drop articles:
  "Me fix code" not "I will fix the code."

### When to Expand

- User asks "explain" — give context, still terse.
- Complex logic needs pseudocode — provide it.
- Architecture decision unclear —
  ask one concise question.
- Otherwise: stay terse.

## Documentation

- Read `README.md` and `AGENTS.md`
  (or `CLAUDE.md` / `GEMINI.md`)
  at the start of every task.
- Keep both files updated when changes affect them.
- `README.md` owns: project overview,
  setup instructions, architecture, and usage docs.
- `AGENTS.md` owns: AI agent workflow, commands,
  and conventions for development.
- Do not duplicate information between the two files.
  Reference `README.md` for project context.

## Git Workflow

- Work in a feature branch, not `main`.
- Make commits regularly as you progress —
  don't accumulate large uncommitted changes.
- Follow [Conventional Commits][cc] for messages:
  - Format: `<type>(<scope>): <description>`
  - Types: `feat`, `fix`, `refactor`, `docs`,
    `test`, `chore`, `ci`, `build`, `perf`, `style`
  - Scope is optional but encouraged
    when it adds clarity.
  - Subject line ≤ 50 characters, imperative mood.
  - Add a body when the "why" isn't obvious
    from the subject.
- Push the feature branch regularly
  so work isn't lost.
- When the task is complete,
  open a pull request against `main`.

[cc]: https://www.conventionalcommits.org/
