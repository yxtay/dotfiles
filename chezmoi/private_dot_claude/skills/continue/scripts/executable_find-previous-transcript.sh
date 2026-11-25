#!/usr/bin/env bash
# Usage: find-previous-transcript.sh <current-session-id>
# Print the path of the project transcript last updated just before the current session started.
set -euo pipefail
[ $# -eq 1 ] || {
  echo "usage: ${0##*/} <current-session-id>" >&2
  exit 2
}

dir="${HOME}/.claude/projects/${PWD//[^[:alnum:]-]/-}"
cur="${dir}/$1.jsonl"
[ -f "$cur" ] || {
  echo "current transcript not found: $cur" >&2
  exit 1
}

# ISO-8601 UTC timestamps compare correctly as strings
start=$(jq -r 'select(.timestamp) | .timestamp' "$cur" | head -n 1)
best="" best_ts=""
for f in "$dir"/*.jsonl; do
  [ "$f" = "$cur" ] && continue
  ts=$(tail -n 50 "$f" | jq -r 'select(.timestamp) | .timestamp' | tail -n 1)
  [[ -n "$ts" && "$ts" < "$start" && "$ts" > "$best_ts" ]] && best=$f best_ts=$ts
done
[ -n "$best" ] || {
  echo "no earlier transcript in $dir" >&2
  exit 1
}

first=$(jq -r 'select(.type == "user" and (.message.content | type == "string")) | .message.content' "$best" | head -n 1 | tr -s '[:space:]' ' ' | cut -c1-120)
echo "previous session: ${best_ts} \"${first}\"" >&2
echo "$best"
