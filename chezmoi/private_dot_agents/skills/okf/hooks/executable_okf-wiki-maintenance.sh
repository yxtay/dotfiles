#!/usr/bin/env bash
# SessionStart/SessionEnd hook: once per calendar day, distill recent cass-memory
# session diaries (written by `cm hook session-end`) into the ~/wiki OKF bundle. Runs on
# both events so it fires whether a session starts fresh or ends normally.
set -euo pipefail

OKF_PLUGIN="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
WIKI_DIR="${OKF_WIKI_DIR:-${HOME}/wiki}"
STATE_FILE="${WIKI_DIR}/.okf-wiki-last-run"
LOCK_FILE="${WIKI_DIR}/.okf-wiki-maintenance.lock"
LOG_FILE="${WIKI_DIR}/.okf-wiki-maintenance.log"
DIARY_DIR="${CASS_MEMORY_DIR:-${HOME}/.local/share/cass-memory}/diary"
PROMPT_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/okf-wiki-review.txt"

[ -f "${PROMPT_FILE}" ] || exit 0
[ -d "${OKF_PLUGIN}" ] || exit 0
mkdir -p "${WIKI_DIR}"
command -v claude &>/dev/null || exit 0
command -v jq &>/dev/null || exit 0
[ -d "${DIARY_DIR}" ] || exit 0

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

# No raw transcript mirror, even if the launcher bypassed zshenv (the prompt may call cass export).
export CASS_RAW_MIRROR=0

# Diaries written since the last run. Cap at the 30 with most accomplishments so one run
# fits a single context. shortcut: diary timestamp is generation time, not session time.
recent_sessions="$(
  jq -s --arg since "${since_date}" '[.[]
      | select(.timestamp >= $since)
      | select(.sessionPath | contains("/subagents/") | not)
      | select((.accomplishments | length) > 0)
      | {sessionPath, workspace, timestamp, accomplishments, decisions, challenges, keyLearnings}]
    | sort_by(-(.accomplishments | length)) | .[:30] | select(length > 0)' \
    "${DIARY_DIR}"/diary-*.json 2>/dev/null || true
)"

# Nothing to distill: record the day so later sessions skip the check.
if [ -z "${recent_sessions}" ]; then
  date +%Y-%m-%d >"${STATE_FILE}"
  exit 0
fi

# hook runs with async:true — Claude Code does not block on this script.
prompt="$(
  printf 'Wiki directory: %s\n' "${WIKI_DIR}"
  printf 'Recent session diaries (JSON):\n%s\n' "${recent_sessions}"
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
