#!/usr/bin/env bash
# Usage: find-previous-transcript.sh <current-session-id>
# Print the path of the project transcript last updated just before the current session started.
# shortcut: a concurrent idle session in the same project can win, and a resumed session's start
# is its first (replayed) timestamp; stderr shows the pick so the caller can catch it.
set -euo pipefail
[ $# -eq 1 ] || {
  echo "usage: ${0##*/} <current-session-id>" >&2
  exit 2
}

# Locate by session id, not $PWD: the project dir is keyed by the session's launch cwd.
cur=$(compgen -G "${HOME}/.claude/projects/*/$1.jsonl" | head -n 1 || true)
[ -n "$cur" ] || {
  echo "current transcript not found for session $1" >&2
  exit 1
}
dir=${cur%/*}

# ISO-8601 UTC timestamps compare correctly as strings
start=$(jq -rn 'first(inputs | select(.timestamp) | .timestamp)' "$cur")
best="" best_ts=""
for f in "$dir"/*.jsonl; do
  [ "$f" = "$cur" ] && continue
  # fromjson? skips a partial line from a session that is mid-write
  ts=$(tail -n 200 "$f" | jq -Rr 'fromjson? | select(.timestamp) | .timestamp' | tail -n 1 || true)
  [[ -n "$ts" && "$ts" < "$start" && "$ts" > "$best_ts" ]] && best=$f best_ts=$ts
done
[ -n "$best" ] || {
  echo "no earlier transcript in $dir" >&2
  exit 1
}

# first real prompt: skip slash-command and caveat wrappers, which start with "<"
first=$(jq -rn 'first(inputs | select(.type == "user" and (.message.content | type == "string") and (.message.content | startswith("<") | not)) | .message.content)' "$best" | tr -s '[:space:]' ' ' | cut -c1-120 || true)
echo "previous session: ${best_ts} \"${first}\"" >&2
echo "$best"
