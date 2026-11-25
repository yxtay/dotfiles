#!/usr/bin/env bash
# Usage: tail-transcript.sh <transcript.jsonl> [n-entries=30]
# Print the last n user/assistant entries of a Claude Code transcript as compact text:
# prompts and replies in full (capped), tool calls and results truncated, thinking skipped.
set -euo pipefail
[ $# -ge 1 ] && [ -f "$1" ] || {
  echo "usage: ${0##*/} <transcript.jsonl> [n-entries=30]" >&2
  exit 2
}
n="${2:-30}"

jq -r --argjson cap 600 '
  def clip: if length > $cap then .[:$cap] + "…" else . end;
  select(.type == "user" or .type == "assistant")
  | .message.content
  | if type == "string" then ["USER", .]
    else .[] | if .type == "text" then ["ASSISTANT", .text]
      elif .type == "tool_use" then ["TOOL", (.name + " " + (.input | tojson))]
      elif .type == "tool_result" then ["RESULT", ((.content | if type == "array" then map(.text // "") | join(" ") else tostring end))]
      else empty end
    end
  | "[\(.[0])] \(.[1] | gsub("\\s+"; " ") | clip)"
' "$1" | tail -n "${n}"
