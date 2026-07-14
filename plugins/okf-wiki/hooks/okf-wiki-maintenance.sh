#!/usr/bin/env bash
# SessionEnd hook: periodically distill memsearch journals into the ~/wiki OKF bundle.
# Independent of the memsearch plugin's own SessionEnd hook — reads its journal output
# as a data source only, no changes to memsearch itself.
set -euo pipefail

# Avoid recursing into our own hooks when the nested `claude -p` below exits.
if [ "${MEMSEARCH_DISABLE:-}" = "1" ] || [ "${OKF_WIKI_DISABLE:-}" = "1" ]; then
  exit 0
fi

MEMSEARCH_DIR="${MEMSEARCH_DIR:-${HOME}/.memsearch}"
JOURNAL_DIR="${MEMSEARCH_DIR}/memory"
WIKI_DIR="${OKF_WIKI_DIR:-${HOME}/wiki}"
STATE_FILE="${WIKI_DIR}/.okf-wiki-last-run"
LOCK_FILE="${WIKI_DIR}/.okf-wiki-maintenance.lock"
PROMPT_FILE="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/prompts/okf-wiki-review.txt"

[ -d "${JOURNAL_DIR}" ] || exit 0
[ -f "${PROMPT_FILE}" ] || exit 0
mkdir -p "${WIKI_DIR}"
command -v claude &>/dev/null || exit 0

# Acquire exclusive lock — prevents concurrent SessionEnd runs.
# fd 9 is opened on LOCK_FILE; flock holds it for this process's lifetime.
exec 9>"${LOCK_FILE}"
flock -n 9 || exit 0 # -n = non-blocking: exit immediately if already locked

# Skip if already ran today (same calendar date).
if [ -f "${STATE_FILE}" ]; then
  last_run_date="$(cat "${STATE_FILE}" 2>/dev/null)"
  today="$(date +%Y-%m-%d)"
  if [ "${last_run_date}" = "${today}" ]; then
    exit 0
  fi
fi

# Only look at journals touched since the last run (falls back to last 3 days on first run).
if [ -f "${STATE_FILE}" ]; then
  recent_journals="$(find "${JOURNAL_DIR}" -maxdepth 1 -name '*.md' -newer "${STATE_FILE}" 2>/dev/null)"
else
  recent_journals="$(find "${JOURNAL_DIR}" -maxdepth 1 -name '*.md' -mtime -3 2>/dev/null)"
fi

[ -n "${recent_journals}" ] || exit 0

# Include memsearch-synthesized summaries if present (higher-signal than raw journals).
extra_context=""
[ -f "${MEMSEARCH_DIR}/PROJECT.md" ] && extra_context="${extra_context}
Project summary: ${MEMSEARCH_DIR}/PROJECT.md"
[ -f "${MEMSEARCH_DIR}/USER.md" ] && extra_context="${extra_context}
User profile:    ${MEMSEARCH_DIR}/USER.md"

export MEMSEARCH_DISABLE=1
export MEMSEARCH_NO_WATCH=1
export OKF_WIKI_DISABLE=1
unset CLAUDECODE # clear CLAUDECODE so the child session doesn't inherit hook context

# hook runs with async:true — Claude Code does not block on this script.
# Run claude -p synchronously so flock holds for the full duration, preventing
# a concurrent trigger from starting a second run.
# Write state file only on success so a failed run does not suppress the next.
if printf 'Wiki directory: %s\nRecently changed journal files:\n%s%s' \
  "${WIKI_DIR}" "${recent_journals}" "${extra_context}" |
  claude -p \
    --strict-mcp-config \
    --no-session-persistence \
    --model haiku \
    --effort low \
    --allowed-tools "Read,Write,Edit,Glob,Grep" \
    --append-system-prompt-file "${PROMPT_FILE}" \
    --add-dir "${WIKI_DIR}" \
    --add-dir "${MEMSEARCH_DIR}" \
    >/dev/null 2>&1; then
  date +%Y-%m-%d >"${STATE_FILE}"
fi

exit 0
