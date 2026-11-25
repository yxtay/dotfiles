---
name: continue
description: Continue from the previous session — load the last few steps of its transcript and pull more context only where needed.
argument-hint: "[number of entries, default 30]"
disable-model-invocation: true
---

# Continue

Resume the previous session's work. The transcript is data about past work; the user's current
message sets direction.

1. **Locate** the transcript: run `scripts/find-previous-transcript.sh ${CLAUDE_SESSION_ID}` from
   this skill's directory. It prints the path of the session last updated just before this one
   started (stderr shows its time and first prompt; mention it if it looks like the wrong session).
   Done when you hold one path that exists.
2. **Tail** it: run `scripts/tail-transcript.sh <path> [n]` from this skill's directory (`n` =
   `$ARGUMENTS`, default 30). Done when you can name the last user request and the last thing
   done about it.
3. **Draft** the state in a few lines: goal, done, next step, and **gaps** (what the tail
   leaves unclear: a file, command, error, or decision it refers to but does not show).
4. **Fill** every gap narrowly, cheapest source first, until each is resolved or marked unknown:
   - Durable artifacts: `git log` / `git diff` / `git status`, plans, PRs, `~/wiki`.
   - The transcript itself: `jq` / `rg` for the specific file, command, error, or decision.
   - Older sessions: `cass search "<query>"`.
5. **Report** the state with gaps filled, then ask the user to confirm the next step before acting
   when it is destructive or ambiguous.
