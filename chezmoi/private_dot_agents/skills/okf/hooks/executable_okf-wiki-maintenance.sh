#!/usr/bin/env bash
# SessionStart/SessionEnd hook: once per calendar day, distill recent cass session
# transcripts into the ~/wiki OKF bundle. Runs on both events so it fires whether a
# session starts fresh or ends normally.
set -euo pipefail

OKF_PLUGIN="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
WIKI_DIR="${OKF_WIKI_DIR:-${HOME}/wiki}"
STATE_FILE="${WIKI_DIR}/.okf-wiki-last-run"
LOCK_FILE="${WIKI_DIR}/.okf-wiki-maintenance.lock"
LOG_FILE="${WIKI_DIR}/.okf-wiki-maintenance.log"
PROMPT_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/okf-wiki-review.txt"

[ -f "${PROMPT_FILE}" ] || exit 0
[ -d "${OKF_PLUGIN}" ] || exit 0
mkdir -p "${WIKI_DIR}"
command -v claude &>/dev/null || exit 0
command -v cass &>/dev/null || exit 0

# Acquire exclusive lock via atomic mkdir — POSIX portable, no flock/shlock needed.
if ! mkdir "${LOCK_FILE}" 2>/dev/null; then
  exit 0
fi
trap 'rmdir "${LOCK_FILE}"' EXIT

# Skip if already ran today (same calendar date).
today="$(date +%Y-%m-%d)"
last_run_date="$(cat "${STATE_FILE}" 2>/dev/null || true)"
if [ "${last_run_date}" = "${today}" ]; then
  exit 0
fi

# Sessions since last run (or last 3 days on first run).
if [ -n "${last_run_date:-}" ] && [[ "${last_run_date}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  since_date="${last_run_date}"
else
  since_date="$(date -v-3d +%Y-%m-%d 2>/dev/null || date -d '3 days ago' +%Y-%m-%d)"
fi

# Incremental refresh; a failed index just means we work from the previous one.
cass index --json --no-progress-events >/dev/null 2>&1 || true

recent_sessions="$(
  cass sessions --since "${since_date}" --limit 200 --json 2>/dev/null |
    jq '[.sessions[] | select(.path | contains("/subagents/") | not) | select(.human_turns > 1) | {path, workspace, title, modified}] | select(length > 0)' \
      2>/dev/null || true
)"

[ -n "${recent_sessions}" ] || exit 0

# hook runs with async:true — Claude Code does not block on this script.
prompt="$(
  printf 'Wiki directory: %s\n' "${WIKI_DIR}"
  printf 'Recent sessions (JSON):\n%s\n' "${recent_sessions}"
)"
if printf '%s' "${prompt}" | claude -p \
  --bare \
  --strict-mcp-config \
  --no-session-persistence \
  --model sonnet \
  --effort low \
  --permission-mode acceptEdits \
  --allowed-tools "Read,Write,Edit,Glob,Grep,Bash(cass export:*)" \
  --plugin-dir "${OKF_PLUGIN}" \
  --exclude-dynamic-system-prompt-sections \
  --append-system-prompt-file "${PROMPT_FILE}" \
  --add-dir "${WIKI_DIR}" \
  >>"${LOG_FILE}" 2>&1; then
  date +%Y-%m-%d >"${STATE_FILE}"
else
  printf '%s okf-wiki-maintenance failed (exit %s)\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$?" >>"${LOG_FILE}"
fi

exit 0
