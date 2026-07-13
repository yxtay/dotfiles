#!/usr/bin/env bash
# SessionEnd / PreCompact hook: periodically distill memsearch journals into the ~/wiki OKF bundle.
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
LOCK_FILE="$MEMSEARCH_DIR/.okf-wiki-maintenance.lock"
PROMPT_FILE="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/okf-wiki-review.txt"

[ -d "$JOURNAL_DIR" ] || exit 0
[ -d "$WIKI_DIR" ] || exit 0
command -v claude &>/dev/null || exit 0

# Acquire exclusive lock — prevents concurrent SessionEnd + PreCompact runs.
exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

# Skip if last run was within MIN_INTERVAL_HOURS.
if [ -f "$STATE_FILE" ]; then
  last_run="$(cat "$STATE_FILE" 2>/dev/null)"
  # Guard: treat empty or non-numeric state file as 0 (never run).
  if ! [[ "$last_run" =~ ^[0-9]+$ ]]; then last_run=0; fi
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

# Include memsearch-synthesized summaries if present (higher-signal than raw journals).
extra_context=""
[ -f "$MEMSEARCH_DIR/PROJECT.md" ] && extra_context="$extra_context\nProject summary: $MEMSEARCH_DIR/PROJECT.md"
[ -f "$MEMSEARCH_DIR/USER.md" ] && extra_context="$extra_context\nUser profile:    $MEMSEARCH_DIR/USER.md"

export MEMSEARCH_DISABLE=1
export MEMSEARCH_NO_WATCH=1
export OKF_WIKI_DISABLE=1
export CLAUDECODE=

# hook runs with async:true — Claude Code does not block on this script.
# Run claude -p synchronously so flock holds for the full duration, preventing
# a concurrent PreCompact trigger from starting a second run.
# Write state file only on success so a failed run does not suppress the next.
if claude -p \
  --strict-mcp-config \
  --no-session-persistence \
  --allowed-tools "Skill,Read,Write,Edit,Glob,Grep" \
  --add-dir "$WIKI_DIR" \
  --add-dir "$JOURNAL_DIR" \
  --add-dir "$MEMSEARCH_DIR" \
  --system-prompt "$(cat "$PROMPT_FILE")" \
  "Journal directory: $JOURNAL_DIR
Wiki directory: $WIKI_DIR
Recently changed journal files:
$recent_journals${extra_context:+
$extra_context}" \
  >/dev/null 2>&1; then
  date +%s >"$STATE_FILE"
fi

exit 0
