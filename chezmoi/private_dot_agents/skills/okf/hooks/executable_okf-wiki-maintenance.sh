#!/usr/bin/env bash
# SessionStart/SessionEnd hook: once per calendar day, distill recent cass-memory
# session diaries (written by `cm hook session-end`) into the ~/wiki OKF bundle, and run
# `cm reflect` to update the cass-memory playbook. Runs on both events so it fires whether
# a session starts fresh or ends normally.
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

# Skip if already ran today (local date of the state file's mtime).
today="$(date +%Y-%m-%d)"
if [ -f "${STATE_FILE}" ] && [ "$(date -r "${STATE_FILE}" +%Y-%m-%d)" = "${today}" ]; then
  exit 0
fi

# State holds the UTC start time of the last successful run, the same clock as diary
# timestamps. Diaries landing after it (the ending session's diary is written in the
# background) are picked up next run. A bare date from an older state file also compares fine.
run_start="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
last_run="$(cat "${STATE_FILE}" 2>/dev/null || true)"
if [[ "${last_run}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9:.]+Z)?$ ]]; then
  since="${last_run}"
else
  since="$(date -u -v-3d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '3 days ago' +%Y-%m-%dT%H:%M:%SZ)"
fi

# Extract playbook rules from recent sessions into cass-memory. Best-effort: a failure must not
# block the wiki run. Idempotent, since cm skips sessions it already processed.
if command -v cm &>/dev/null; then
  cm reflect --days 2 --max-sessions 20 --json >>"${LOG_FILE}" 2>&1 ||
    printf '%s cm reflect failed\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >>"${LOG_FILE}"
fi

# Every diary written since the last run, oldest first. Per-file parse so one truncated diary
# does not drop the rest. shortcut: diary timestamp is generation time, not session time.
recent_sessions="$(
  for f in "${DIARY_DIR}"/diary-*.json; do jq -c . "${f}" 2>/dev/null || true; done |
    jq -s --arg since "${since}" '[.[]
        | select(.timestamp >= $since)
        | select(.sessionPath | contains("/subagents/") | not)
        | select(((.accomplishments // []) + (.decisions // []) + (.challenges // []) + (.keyLearnings // [])) | length > 0)
        | {sessionPath, workspace, timestamp, status, accomplishments, decisions, challenges, keyLearnings, preferences}]
      | sort_by(.timestamp) | select(length > 0)'
)" || exit 0

# Nothing to distill: record the run so later sessions today skip the check.
if [ -z "${recent_sessions}" ]; then
  printf '%s\n' "${run_start}" >"${STATE_FILE}"
  exit 0
fi

# hook runs with async:true — Claude Code does not block on this script.
# Batches of 30 diaries keep each run within one context; state advances only if all succeed.
ok=1
while IFS= read -r batch; do
  prompt="$(
    printf 'Wiki directory: %s\n' "${WIKI_DIR}"
    printf 'Recent session diaries (JSON):\n%s\n' "${batch}"
  )"
  if ! printf '%s' "${prompt}" | claude -p \
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
    ok=0
    printf '%s okf-wiki-maintenance batch failed\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >>"${LOG_FILE}"
    break
  fi
done < <(printf '%s' "${recent_sessions}" | jq -c '. as $a | range(0; length; 30) | $a[.:.+30]')

if [ "${ok}" = 1 ]; then
  printf '%s\n' "${run_start}" >"${STATE_FILE}"
fi

exit 0
