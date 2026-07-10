<!-- markdownlint-disable MD013 -->

# Context & Knowledge Management: What Actually Helps Beyond "Keep CLAUDE.md Short"

Research date: 2026-07-10
Scope: primary sources first (code.claude.com/docs/en/*, anthropic.com/engineering / claude.com/blog), then well-known secondary/community patterns, explicitly labeled. This deliberately excludes generic file-size hygiene — see `RESEARCH-global-agents-md.md` for that.
Starting point: the user's existing `~/.claude/AGENTS.md` already has a Context Management section (scoped search, subagent delegation for raw-content tool calls) and a Knowledge Wiki section (`~/wiki/` OKF bundle, read-index-at-start, write-as-you-go, search-before-writing). This report looks for concrete refinements and gaps, not a rewrite.

---

## 1. Session continuity / context handoff

**Primary source: [code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory), [code.claude.com/docs/en/context-window](https://code.claude.com/docs/en/context-window)**

Claude Code ships two genuinely distinct, officially-supported continuity mechanisms — worth distinguishing sharply because they solve different problems:

**Auto memory (`MEMORY.md`)** — Claude's own self-written notes, not user-authored:

- "Auto memory lets Claude accumulate knowledge across sessions without you writing anything. Claude saves notes for itself as it works... Claude doesn't save something every session. It decides what's worth remembering."
- Stored per-repo at `~/.claude/projects/<project>/memory/`, shared across all worktrees of that repo, but **machine-local only** — "Files are not shared across machines or cloud environments."
- Hard cap: first 200 lines / 25KB loaded at session start; excess silently not loaded. (Contrast: CLAUDE.md has no such cap.)
- Toggle: `/memory`, `autoMemoryEnabled` setting, or `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`.
- Requires Claude Code ≥ v2.1.59.

*Practical implication*: this already exists and is running for the user (confirmed — their memory file `MEMORY.md` under `.claude/projects/-Users-yuxuantay-git-dotfiles/memory/` is visible in this session's context). It is a genuine second knowledge layer alongside the user's own `~/wiki/` — they are not redundant: auto memory is Claude's *unprompted, per-repo* observations; `~/wiki/` is the user's *curated, cross-project* durable knowledge base. Nothing needs to change here, but it's worth knowing auto memory exists so the wiki isn't duplicating what Claude already self-remembers per-repo.

**Compaction (`/compact`, auto-compaction)** — what survives when context fills up:

- "Compaction is the practice of taking a conversation nearing the context window limit, summarizing its contents, and reinitiating a new context window with the summary. The model typically preserves architectural decisions, unresolved bugs, and implementation details while discarding redundant tool outputs or messages." (Anthropic engineering blog, ["Effective context engineering for AI agents"](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents), Sept 2025 — primary source)
- Exact survival table from the docs (`code.claude.com/docs/en/context-window`, "What survives compaction"):

  | Item | Fate at compaction |
  | --- | --- |
  | Project-root CLAUDE.md and unscoped rules | Re-injected from disk |
  | Auto memory | Re-injected from disk |
  | Rules with `paths:` frontmatter | **Lost** until a matching file is read again |
  | Nested CLAUDE.md in subdirectories | **Lost** until a file in that subdirectory is read again |
  | Invoked skill bodies | Re-injected, capped at 5,000 tokens/skill, 25,000 tokens total, oldest dropped first |
  | System prompt / output style | Unchanged |
  | Skill *index* (descriptions) | **Not** re-injected — only skills actually invoked are preserved |

  **Actionable implication**: if the user relies on path-scoped rules or nested CLAUDE.md files for anything load-bearing in a long session, compaction silently drops them until the matching file is touched again. This is a real gap for long sessions working across subdirectories with their own rules — worth knowing, not necessarily worth acting on unless it bites.
- User control over what's kept: `/compact <instructions>` accepts focus text, e.g. `/compact Focus on code samples and API usage`, and a persistent version can live in CLAUDE.md:

  ```markdown
  # Compact instructions
  When you are using compact, please focus on test output and code changes
  ```

  This is a genuinely actionable, low-cost addition: a one-time "compact instructions" block in a project's CLAUDE.md steers every future auto-compaction in that project toward what actually matters for that codebase (e.g., "preserve which files were modified and why," "preserve open questions," "discard exploratory dead ends").

**Structured note-taking (agentic memory)** — Anthropic's own generalized name for the pattern the user already partially has:

- "Structured note-taking, or agentic memory, is a technique where the agent regularly writes notes persisted to memory outside of the context window... giving the agent persistent memory with minimal overhead." (same Anthropic post)
- This is the same underlying idea as `~/wiki/` and MEMORY.md — Anthropic names it as a first-class context-engineering technique, which validates the existing wiki convention rather than suggesting a new mechanism.

**Session resumption (`--continue` / `--resume`)** — primary source, CLI reference:

- `--continue` loads "the most recent conversation in the current directory." `--resume` resumes by ID/name or shows a picker.
- Under the hood: `code.claude.com/docs/en/costs` notes background jobs run "conversation summarization" specifically "for the `claude --resume` feature" — i.e. resumption is powered by a pre-computed summary, not a raw transcript replay. No user action needed; this is automatic.

**What is NOT an official mechanism**: a user-maintained "progress.md" / "TODO.md" handoff file for session-to-session continuity has no Anthropic-blessed slot analogous to CLAUDE.md or MEMORY.md. If the user wants this pattern, it's a manual convention layered on top (see Section 4, community patterns) — not something Claude Code auto-reads. Auto memory already substantially covers this need for free; a hand-rolled progress file would be duplicating a mechanism that already exists, unless the user specifically wants something auto memory doesn't do (e.g. survives a full CLAUDE_CODE_DISABLE_AUTO_MEMORY-off machine change, or a plan that must be human-legible before Claude decides to save it).

**`CLAUDE.local.md`** — gitignored, personal, project-specific:

- "For private per-project preferences that shouldn't be checked into version control... It loads alongside CLAUDE.md and is treated the same way." Example uses given: "Your sandbox URLs, preferred test data."
- Worktree caveat (primary source, easy to miss): "If you work across multiple git worktrees of the same repository, a gitignored `CLAUDE.local.md` only exists in the worktree where you created it. To share personal instructions across worktrees, import a file from your home directory instead." — relevant since the user's AGENTS.md/CLAUDE.md workflow already crosses worktrees (`EnterWorktree` tool available in this environment); if they ever adopt CLAUDE.local.md for scratch/session state, this is a real gotcha, not a hypothetical one.

---

## 2. Codebase knowledge caching (wiki vs. derive-fresh)

**No single official Anthropic ruling on "wiki vs. re-derive" was found** — this is a judgment call the docs leave to the user, but two primary-sourced principles bound it:

1. **Anthropic's own "just-in-time" framing** (context-engineering post) applies directly: "Rather than pre-processing all relevant data up front, agents ... maintain lightweight identifiers (file paths, stored queries, web links, etc.) and use these references to dynamically load data into context at runtime." Anthropic recommends a **hybrid**, not one extreme: "retrieving some data up front for speed, and pursuing further autonomous exploration at its discretion."
   - *Applied to the wiki*: this is an argument for keeping wiki concept files thin and pointer-heavy (file paths, decision rationale, "why," gotchas) rather than restating derivable facts (current function signatures, file structure) that go stale and that Claude can re-derive cheaply via Read/Grep/codebase-memory-mcp anyway. The wiki's comparative advantage over "derive fresh" is exactly the information code *can't* recover on its own: intent, rejected alternatives, workarounds and the bug/constraint that necessitated them, values chosen for non-obvious reasons.
2. **Anthropic's `/doctor` tooling principle**, already documented in the sibling research file: `/doctor` "proposes trimming checked-in CLAUDE.md files by cutting content Claude could derive from the codebase." Same logic applies to wiki concept files even though `/doctor` doesn't scan `~/wiki/` — the staleness risk is identical: anything that's a *fact about current code* rots the moment the code changes; anything that's a *decision or gotcha* doesn't, because the reasoning stays true even after the code around it changes.

**Concrete rule of thumb to fold into the wiki's existing "Write" guidance** (which already says "durable fact, decision, or gotcha"): the existing wording is already correctly scoped to non-derivable content — no change needed there. The one gap: there's no explicit "staleness pruning" trigger analogous to `/doctor`. The wiki convention says "fix or remove entries you find stale... when editing a topic file" — this is reactive (only triggered by touching that file). Nothing prompts revisiting a concept file that hasn't been touched in months even though the code it describes has since changed substantially. This is a real, unaddressed gap — see Section 4 for how community "decision log" patterns handle it (mostly: they don't solve it either, beyond dated log entries that let a human/agent judge staleness by age).

**ADRs (Architecture Decision Records)** — a well-known, non-Anthropic-specific software pattern (not AI-agent-specific), worth naming since the user's wiki functions like one: an ADR's core discipline — record the decision, the context that forced it, and the alternatives rejected, and treat it as immutable once written (superseded by a new ADR, never edited in place) — is a slightly different discipline from the wiki's "amend in place" default. For genuinely one-way architectural decisions (not evolving gotchas), an immutable append-only record with a superseded-by link may resist staleness better than an amend-in-place concept file, because the historical record doesn't need to track current truth — it just needs to be dated. This is a secondary/general software-engineering pattern, not an AI-specific one, but it is a concrete refinement worth considering for the `log.md` files already used at each wiki directory level: treat `log.md` entries as ADR-style immutable stamps (what was decided, when, why) rather than an editable summary, while concept files stay mutable/current-state.

---

## 3. Context budget hygiene during active work

**Primary source: [code.claude.com/docs/en/best-practices](https://code.claude.com/docs/en/best-practices), [code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents), [code.claude.com/docs/en/costs](https://code.claude.com/docs/en/costs), [code.claude.com/docs/en/commands](https://code.claude.com/docs/en/commands)**

The user's AGENTS.md already codifies subagent delegation for raw-content pulls — that's the single most impactful lever and it's already adopted. Concrete refinements/additions found:

1. **A numeric, named failure pattern for un-scoped exploration** — directly matches the AGENTS.md line "Don't let exploration fill context": "**The infinite exploration.** You ask Claude to 'investigate' something without scoping it. Claude reads hundreds of files, filling the context. **Fix**: Scope investigations narrowly or use subagents so the exploration doesn't consume your main context." This is exact confirmation the existing rule already targets a documented, named failure mode — no change needed, just validates the instruction is well-aimed.

2. **A concrete, numeric "start fresh" heuristic — this is new and worth adding.** The user's AGENTS.md has no guidance on *when to abandon a session*, only how to manage what enters it. Anthropic's own heuristic, verified verbatim:
   > "If you've corrected Claude more than twice on the same issue in one session, the context is cluttered with failed approaches. Run `/clear` and start fresh with a more specific prompt that incorporates what you learned. A clean session with a better prompt almost always outperforms a long session with accumulated corrections."
   This is genuinely actionable and currently missing from the user's instructions: a **numeric trigger (2 corrections)** rather than a vague "if things feel stuck." Worth adding verbatim or near-verbatim to the Context Management section.

3. **`/context` command for visibility** — "Visualize current context usage as a colored grid. Shows optimization suggestions for context-heavy tools, memory bloat, and capacity warnings." This is a diagnostic the user can run manually; not something to encode as an instruction (Claude running it on itself mid-task has limited value — it's a human-facing dashboard), but worth knowing exists as a manual habit for the user, not the agent.

4. **Subagents also control cost, not just context, via model routing** — "Control costs by routing tasks to faster, cheaper models like Haiku" (sub-agents doc). The user's AGENTS.md already says "Default to a lighter model (e.g. haiku) unless the task needs deeper reasoning" — already aligned, no gap.

5. **Forks are the one exception to "subagents start clean" — worth knowing, not necessarily acting on.** "A fork is a subagent that inherits the entire conversation so far instead of starting fresh... The fork's own tool calls still stay out of your conversation and only its final result comes back." This is a genuine escape hatch for cases where a subagent needs full prior context (e.g. continuing a half-finished investigation without re-establishing it) while still keeping its *own* tool-call noise out of the parent. Not currently mentioned in AGENTS.md; worth a one-line addition since it's the answer to "what if the task needs context but I still don't want the raw tool output back."

6. **MCP tool-definition deferral is automatic, not something to instruct** — "MCP tool definitions are deferred by default, so only tool names enter context until Claude uses a specific tool." No action needed; confirms MCP tool bloat is already mitigated at the platform level, and a `MAX_MCP_OUTPUT_TOKENS` setting exists as a knob if a specific MCP server's results are verbose — an environment/settings-level fix, not a prose instruction, consistent with the "hooks/settings for deterministic behavior, prose for judgment calls" split already established in the sibling research file.

7. **Anthropic's own multi-agent cost caveat — worth a one-line caution in AGENTS.md if delegation ever becomes overused.** From "How we built our multi-agent research system": "Agents typically use about 4× more tokens than chat interactions, and multi-agent systems use about 15× more tokens than chats... multi-agent systems require tasks where the value of the task is high enough to pay for the increased performance." The existing AGENTS.md already has an escape valve for this ("Skip delegation for small, targeted reads... or when a subagent's result was wrong or incomplete and fixing it would need repeated round-trips") — this is good and already anticipates the failure mode Anthropic's own data warns about (over-delegating trivial work). No change needed, just confirms the exclusion clause is well-founded.

---

## 4. Knowledge organization patterns (what keeps a wiki alive, not rotting)

**Primary-sourced validation, already covered above**: Anthropic names "structured note-taking / agentic memory" as a first-class pattern and recommends thin, pointer-heavy, just-in-time-loadable knowledge over exhaustive pre-loaded dumps — this validates the wiki's existing thin-index-plus-linked-detail-files structure (`index.md` + topic files, loaded on demand).

**Everything below this line is secondary/community — clearly non-Anthropic, named patterns, evaluated for concrete mechanics worth borrowing:**

- **Cline's "Memory Bank"** ([docs.cline.bot/prompting/cline-memory-bank](https://docs.cline.bot/prompting/cline-memory-bank)) — a prose-instruction convention (not a platform feature) using six fixed files: `projectbrief.md`, `productContext.md`, `activeContext.md`, `systemPatterns.md`, `techContext.md`, `progress.md`. Read trigger is a hard "MUST read ALL memory bank files at the start of EVERY task." Write trigger is an explicit user command ("update memory bank"), not automatic. **Relevant idea worth borrowing**: the *fixed taxonomy* (a slot specifically for "active/current work state" vs. a slot for "stable architecture facts" vs. a slot for "decision history") is more prescriptive than the user's current "organize by topic freely" wiki rule. The user's freeform organization is a deliberate, reasonable choice for a personal cross-project wiki (topics vary too much for one fixed schema to fit), but Cline's `activeContext.md` concept — a single, always-current "what am I in the middle of" file, separate from stable topic knowledge — has no analog in the current wiki setup and *is* a gap: nothing distinguishes "durable topic knowledge" from "what's in flight right now," and the latter is exactly the category MEMORY.md/auto-memory already covers per-repo. Verdict: **don't adopt Cline's full fixed-file taxonomy** (it's overkill for a personal wiki and duplicates auto memory), but the underlying distinction it encodes — stable knowledge vs. in-flight state — is already handled by the division of labor between `~/wiki/` (stable) and auto memory (in-flight, per-repo). Worth stating that division explicitly in AGENTS.md so it's not accidentally re-invented.

- **Aider's conventions files** ([aider.chat/docs/usage/conventions.html](https://aider.chat/docs/usage/conventions.html)) — a plain read-only markdown file loaded every invocation (`--read CONVENTIONS.md` or `.aider.conf.yml`). No cross-session memory feature at all — "persistence" is just re-supplying the same static file. Not applicable to Claude Code (which already has CLAUDE.md for this), included for completeness: confirms Claude Code's memory/wiki story is materially more advanced than aider's, so no gap to borrow from here.

- **Cognition (Devin team) — "Don't Build Multi-Agents"** (cognition.com/blog/dont-build-multi-agents, vendor/community blog, not Anthropic) — argues *against* parallel multi-agent decomposition for anything beyond narrow single-question lookups, proposing instead a dedicated compression sub-task that summarizes history into key decisions/events specifically to fight context rot. This is a **dissenting view** worth flagging: it's more conservative about subagent fan-out than Anthropic's own multi-agent research post, and roughly agrees with the token-cost caution in Section 3 point 7. Practical takeaway for the user: their existing exclusion clause ("skip delegation for small, targeted reads... or when a subagent's result was wrong or incomplete") already tracks this caution; no change needed, but it's corroborating evidence the exclusion clause is right, not overcautious.

- **Harper Reed's LLM codegen workflow** (harper.blog, individual blog, widely cited in the AI-coding community) — names concrete session-scoped files: `spec.md`, `prompt_plan.md`, `todo.md` (a checklist gating progression to the next step), `output.txt` (full codebase dump for brownfield work). This is a **task-scoped planning pattern**, not a cross-session knowledge pattern — closer to what Claude Code's own plan mode / TodoWrite already do natively. No gap here either; the plan-file idea is already subsumed by built-in plan-mode tooling.

- **"Karpathy's LLM Wiki" pattern**, cited by community repos like `claude-obsidian` (github.com/AgriciDaniel/claude-obsidian) — a global, cross-project Obsidian vault referenced from CLAUDE.md, with skills for `wiki-ingest`, `wiki-query`, `wiki-lint`, `wiki-retrieve`, and a `hot.md` "recently relevant" cache refreshed at session end. **This is structurally the closest community analog to the user's existing `~/wiki/` + OKF setup** — same core idea (persistent cross-project markdown knowledge base, read at session start). The one feature it has that the user's setup doesn't: an explicit **lint skill** (`wiki-lint`) that checks the wiki itself for staleness/broken links/orphaned files as a maintenance pass, separate from the reactive "fix when you happen to touch it" rule. This directly addresses the staleness-pruning gap named in Section 2 — a periodic (not just reactive) consistency/staleness pass over the wiki, possibly as an occasional skill invocation rather than an always-on instruction (to avoid token cost every session).

---

## Concrete, prioritized recommendations

Ranked by leverage-to-effort ratio, each tagged with source confidence:

1. **[Primary, high confidence] Add a numeric "abandon session" trigger.** Add Anthropic's own heuristic — more than two corrections on the same issue in one session → `/clear` and restart with a sharper prompt — to the Context Management section. This is the single clearest gap: the user has rules for what enters context, none for when to give up on a contaminated session.
2. **[Primary, high confidence] Add project-level "compact instructions" as a habit, not a global rule.** Where a project has a recognizable "what matters to preserve" shape (e.g. this dotfiles repo: which files changed and why), a `# Compact instructions` block in that project's CLAUDE.md steers auto-compaction. Not global-file material (it's inherently project-specific), but worth noting in AGENTS.md as a technique to reach for.
3. **[Primary, medium confidence] Name the fork exception for delegation.** Add one line: when a subagent needs full prior context (not just a fresh scoped task) but its own tool noise still shouldn't return to the parent, use a fork rather than a fresh subagent.
4. **[Primary + secondary, medium confidence] Make the wiki/auto-memory division of labor explicit.** State outright in AGENTS.md that `~/wiki/` holds durable, cross-project knowledge while Claude's own per-repo auto memory (`MEMORY.md`) already covers in-flight, repo-scoped state — so the user doesn't end up manually duplicating what auto memory does for free, and so future-Claude doesn't invent a redundant "progress.md" habit.
5. **[Secondary, medium confidence] Add a periodic wiki staleness pass, distinct from the existing reactive rule.** Borrowing the `wiki-lint`-style idea: occasionally (not every session) sweep `~/wiki/` for concept files that reference code/decisions that have since changed, rather than relying solely on "fix it when you happen to edit that file." Could be a manual periodic invocation rather than an always-on instruction, to avoid a permanent token tax.
6. **[Secondary, lower confidence, optional] Treat `log.md` entries as immutable, ADR-style stamps** (dated, append-only, superseded-by links) rather than editable summaries, while concept files stay mutable — reduces the chance a log file itself becomes a second copy of "current truth" that also goes stale.

---

## Source list

**Primary (Anthropic official docs / engineering blog):**

- [code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory) — auto memory mechanics, size cap, CLAUDE.local.md, worktree caveat
- [code.claude.com/docs/en/context-window](https://code.claude.com/docs/en/context-window) — compaction survival table
- [code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents) — context isolation, forks, cost routing
- [code.claude.com/docs/en/best-practices](https://code.claude.com/docs/en/best-practices) — infinite-exploration failure pattern, `/clear` heuristic (verified verbatim directly)
- [code.claude.com/docs/en/costs](https://code.claude.com/docs/en/costs) — token scaling, background resume-summarization jobs, subagent delegation for cost
- [code.claude.com/docs/en/commands](https://code.claude.com/docs/en/commands) — `/compact`, `/context` exact descriptions (verified verbatim directly)
- [code.claude.com/docs/en/mcp](https://code.claude.com/docs/en/mcp) — deferred MCP tool-definition loading
- [anthropic.com/engineering/effective-context-engineering-for-ai-agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) (Sept 2025) — compaction definition, structured note-taking/agentic memory, just-in-time vs. pre-loading
- [anthropic.com/engineering/built-multi-agent-research-system](https://www.anthropic.com/engineering/built-multi-agent-research-system) (June 2025, older; generalized by the Sept 2025 post above) — subagent orchestration mechanics, 4x/15x token cost figures
- [claude.com/blog/context-management](https://claude.com/blog/context-management) (Sept 2025; `anthropic.com/news/context-management` redirects here) — API-level memory tool, context editing, 39%/29% eval improvement figures

**Secondary/community (clearly non-Anthropic, labeled throughout):**

- [docs.cline.bot/prompting/cline-memory-bank](https://docs.cline.bot/prompting/cline-memory-bank) — Cline Memory Bank fixed-file convention
- [aider.chat/docs/usage/conventions.html](https://aider.chat/docs/usage/conventions.html) — Aider CONVENTIONS.md read-only loading
- [cognition.com/blog/dont-build-multi-agents](https://cognition.com/blog/dont-build-multi-agents) — dissenting view on multi-agent fan-out, compression-over-parallelism
- [langchain.com/blog/the-rise-of-context-engineering](https://www.langchain.com/blog/the-rise-of-context-engineering) — conceptual, thinner corroboration
- [harper.blog/2025/02/16/my-llm-codegen-workflow-atm](https://harper.blog/2025/02/16/my-llm-codegen-workflow-atm/) — spec/plan/todo file planning pattern (task-scoped, not cross-session)
- [github.com/AgriciDaniel/claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian) — "Karpathy's LLM Wiki" pattern, closest community analog to the user's `~/wiki/` setup, includes a wiki-lint staleness-check skill
- [github.com/centminmod/my-claude-code-setup](https://github.com/centminmod/my-claude-code-setup) — another named "CLAUDE.md memory bank" repo, contents not independently verified beyond confirming it exists

Architecture Decision Records (ADRs) are referenced as a general software-engineering pattern, not tied to a single canonical source — included because the wiki's `log.md` convention resembles one.
