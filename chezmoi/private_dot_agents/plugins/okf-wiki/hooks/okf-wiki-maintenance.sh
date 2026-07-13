#!/usr/bin/env bash
# SessionEnd hook: periodically distill memsearch journals into the ~/wiki OKF bundle.
# Independent of the memsearch plugin's own SessionEnd hook — reads its journal output
# as a data source only, no changes to memsearch itself.
set -euo pipefail

# Avoid recursing into our own hooks when the nested `claude -p` below exits.
if [ "${MEMSEARCH_DISABLE:-}" = "1" ] || [ "${OKF_WIKI_DISABLE:-}" = "1" ]; then
  exit 0
fi

MIN_INTERVAL_HOURS="${OKF_WIKI_MIN_INTERVAL_HOURS:-24}"
MEMSEARCH_DIR="${MEMSEARCH_DIR:-$HOME/.memsearch}"
JOURNAL_DIR="$MEMSEARCH_DIR/memory"
WIKI_DIR="${OKF_WIKI_DIR:-$HOME/wiki}"
STATE_FILE="$MEMSEARCH_DIR/.okf-wiki-last-run"
PROMPT_FILE="${CLAUDE_PLUGIN_ROOT}/okf-wiki-review.txt"

[ -d "$JOURNAL_DIR" ] || exit 0
command -v claude &>/dev/null || exit 0

# Skip if last run was within MIN_INTERVAL_HOURS.
if [ -f "$STATE_FILE" ]; then
  last_run="$(cat "$STATE_FILE" 2>/dev/null || echo 0)"
  now="$(date +%s)"
  elapsed_hours=$(((now - last_run) / 3600))
  if [ "$elapsed_hours" -lt "$MIN_INTERVAL_HOURS" ]; then
    exit 0
  fi
fi

# Only look at journals touched since the last run (falls back to last 3 days on first run).
if [ -f "$STATE_FILE" ]; then
  recent_journals="$(find "$JOURNAL_DIR" -maxdepth 1 -name '*.md' -newer "$STATE_FILE" 2>/dev/null)"
else
  recent_journals="$(find "$JOURNAL_DIR" -maxdepth 1 -name '*.md' -mtime -3 2>/dev/null)"
fi

[ -n "$recent_journals" ] || exit 0

date +%s >"$STATE_FILE"

export MEMSEARCH_DISABLE=1
export MEMSEARCH_NO_WATCH=1
export CLAUDECODE=

claude -p \
  --strict-mcp-config \
  --no-session-persistence \
  --allowed-tools "Skill,Read,Write,Edit,Glob,Grep" \
  --add-dir "$WIKI_DIR" \
  --add-dir "$JOURNAL_DIR" \
  --system-prompt "$(cat "$PROMPT_FILE")" \
  "Journal directory: $JOURNAL_DIR
Wiki directory: $WIKI_DIR
Recently changed journal files:
$recent_journals" \
  >/dev/null 2>&1 || true

exit 0
