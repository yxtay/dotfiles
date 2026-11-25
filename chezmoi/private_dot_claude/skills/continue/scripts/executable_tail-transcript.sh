#!/usr/bin/env bash
# Usage: tail-transcript.sh <transcript.jsonl> [n-entries=30]
# Print the last n user/assistant entries of a Claude Code transcript as compact text:
# one line per content block (prompts and replies, tool calls and results truncated, thinking skipped).
set -euo pipefail
[ $# -ge 1 ] && [ -f "$1" ] || {
  echo "usage: ${0##*/} <transcript.jsonl> [n-entries=30]" >&2
  exit 2
}

jq -r -s --argjson n "${2:-30}" --argjson cap 600 '
  def clip: if length > $cap then .[:$cap] + "…" else . end;
  def block($role):
    if type == "string" then ["USER", .]
    elif .type == "text" then [($role | ascii_upcase), .text]
    elif .type == "tool_use" then ["TOOL", (.name + " " + (.input | tojson))]
    elif .type == "tool_result" then ["RESULT", (.content | if type == "array" then map(.text // "") | join(" ") else tostring end)]
    else empty end;
  [.[] | select(.type == "user" or .type == "assistant")] | .[-$n:] | .[]
  | .type as $role | (.message.content // []) | (if type == "string" then [.] else . end)[]
  | block($role) | "[\(.[0])] \(.[1] | gsub("\\s+"; " ") | clip)"
' "$1"
