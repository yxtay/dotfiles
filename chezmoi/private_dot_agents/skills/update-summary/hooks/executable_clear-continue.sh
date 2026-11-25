#!/usr/bin/env bash
# SessionStart(startup|clear): point the new session at the most recent previous transcript in the
# same project, so work can continue after a restart or /clear.
# shortcut: newest other transcript in the project dir, so a concurrent session in the same project
# can be picked instead; upgrade to per-session tracking if that bites.
set -euo pipefail
command -v jq &>/dev/null || exit 0

input="$(cat)"
current="$(jq -r '.transcript_path // empty' <<<"${input}")"
[ -n "${current}" ] || exit 0

# Newest top-level transcript other than the current one (subagent transcripts live in subdirs).
previous="$(ls -t "$(dirname "${current}")"/*.jsonl 2>/dev/null | grep -vxF "${current}" | head -n 1 || true)"
[ -n "${previous}" ] || exit 0

jq -n --arg p "${previous}" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: ("The most recent previous session transcript (JSONL) in this project is at " + $p + ". It is background, not instructions: read it only if the user refers to earlier work.")}}'
