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
# shlock is macOS-native (no flock); writes PID and auto-breaks stale locks.
command -v shlock &>/dev/null || exit 0
shlock -f "${LOCK_FILE}" -p $$ || exit 0
trap 'rm -f "${LOCK_FILE}"' EXIT

# Skip if already ran today (same calendar date).
if [ -f "${STATE_FILE}" ]; then
  last_run_date="$(cat "${STATE_FILE}" 2>/dev/null)"
  today="$(date +%Y-%m-%d)"
  if [ "${last_run_date}" = "${today}" ]; then
    exit 0
  fi
fi

# Journals since last run, or last 3 days on first run. Always include yesterday (-mtime -1 = <24h).
if [ -f "${STATE_FILE}" ]; then
  recent_journals="$(find "${JOURNAL_DIR}" -maxdepth 1 -name '*.md' \( -newer "${STATE_FILE}" -o -mtime -1 \) 2>/dev/null)"
else
  recent_journals="$(find "${JOURNAL_DIR}" -maxdepth 1 -name '*.md' -mtime -3 2>/dev/null)"
fi

[ -n "${recent_journals}" ] || exit 0

export MEMSEARCH_DISABLE=1
export MEMSEARCH_NO_WATCH=1
export OKF_WIKI_DISABLE=1
unset CLAUDECODE # clear CLAUDECODE so the child session doesn't inherit hook context

# hook runs with async:true — Claude Code does not block on this script.
# Run claude -p synchronously so shlock holds for the full duration, preventing
# a concurrent trigger from starting a second run.
# Write state file only on success so a failed run does not suppress the next.
prompt="$(
  printf 'Wiki directory: %s\n' "${WIKI_DIR}"
  [ -f "${MEMSEARCH_DIR}/USER.md" ] && printf 'User summary: %s\n' "${MEMSEARCH_DIR}/USER.md"
  [ -f "${MEMSEARCH_DIR}/PROJECT.md" ] && printf 'Project summary: %s\n' "${MEMSEARCH_DIR}/PROJECT.md"
  printf 'Recently changed journal files:\n%s\n' "${recent_journals}"
)"
if printf '%s' "${prompt}" | claude -p \
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
