#!/usr/bin/env bash
# SessionStart/SessionEnd hook: once per calendar day, distill memsearch memories into
# the ~/wiki OKF bundle. Runs on both events so it fires whether a session starts fresh
# or ends normally. Independent of the memsearch plugin — reads its memory output as a
# data source only, no changes to memsearch itself.
set -euo pipefail

MEMSEARCH_DIR="${MEMSEARCH_DIR:-${HOME}/.memsearch}"
JOURNAL_DIR="${MEMSEARCH_DIR}/memory"
WIKI_DIR="${OKF_WIKI_DIR:-${HOME}/wiki}"
STATE_FILE="${WIKI_DIR}/.okf-wiki-last-run"
LOCK_FILE="${WIKI_DIR}/.okf-wiki-maintenance.lock"
PROMPT_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/okf-wiki-review.txt"

[ -d "${JOURNAL_DIR}" ] || exit 0
[ -f "${PROMPT_FILE}" ] || exit 0
mkdir -p "${WIKI_DIR}"
command -v claude &>/dev/null || exit 0

# Acquire exclusive lock via atomic mkdir — POSIX portable, no flock/shlock needed.
if ! mkdir "${LOCK_FILE}" 2>/dev/null; then
  exit 0
fi
trap 'rmdir "${LOCK_FILE}"' EXIT

# Skip if already ran today (same calendar date).
if [ -f "${STATE_FILE}" ]; then
  last_run_date="$(cat "${STATE_FILE}" 2>/dev/null)"
  today="$(date +%Y-%m-%d)"
  if [ "${last_run_date}" = "${today}" ]; then
    exit 0
  fi
fi

# Memories since last run, or past day on first run.
if [ -f "${STATE_FILE}" ]; then
  recent_memories="$(find "${JOURNAL_DIR}" -maxdepth 1 -name '*.md' \( -newer "${STATE_FILE}" -o -mtime -1 \) 2>/dev/null)"
else
  recent_memories="$(find "${JOURNAL_DIR}" -maxdepth 1 -name '*.md' -mtime -1 2>/dev/null)"
fi

[ -n "${recent_memories}" ] || exit 0

# hook runs with async:true — Claude Code does not block on this script.
# Run claude -p synchronously so mkdir lock holds for the full duration,
# preventing a concurrent trigger from starting a second run.
# Write state file only on success so a failed run does not suppress the next.
prompt="$(
  printf 'Wiki directory: %s\n' "${WIKI_DIR}"
  [ -f "${MEMSEARCH_DIR}/USER.md" ] && printf 'User profile: %s\n' "${MEMSEARCH_DIR}/USER.md"
  [ -f "${MEMSEARCH_DIR}/PROJECT.md" ] && printf 'Project review: %s\n' "${MEMSEARCH_DIR}/PROJECT.md"
  printf 'Recent memory:\n%s\n' "${recent_memories}"
)"
if printf '%s' "${prompt}" | claude -p \
  --bare \
  --no-session-persistence \
  --model haiku \
  --effort low \
  --permission-mode acceptEdits \
  --allowed-tools "Read,Write,Edit,Glob,Grep" \
  --plugin-dir "${HOME}/.claude/skills/okf" \
  --exclude-dynamic-system-prompt-sections \
  --append-system-prompt-file "${PROMPT_FILE}" \
  --add-dir "${WIKI_DIR}" \
  --add-dir "${MEMSEARCH_DIR}" \
  >/dev/null 2>&1; then
  date +%Y-%m-%d >"${STATE_FILE}"
fi

exit 0
