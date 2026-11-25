#!/usr/bin/env bash
# SessionEnd(clear): remember the ending session's transcript path, keyed by cwd.
# SessionStart(clear): inject that path as context, once, if it is fresh.
set -euo pipefail
command -v jq &>/dev/null || exit 0

STATE_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/claude-clear-continue"
MAX_AGE_SECONDS=60

input="$(cat)"
event="$(jq -r '.hook_event_name // empty' <<<"${input}")"
cwd="$(jq -r '.cwd // empty' <<<"${input}")"
[ -n "${cwd}" ] || exit 0
state_file="${STATE_DIR}/$(printf '%s' "${cwd}" | shasum | cut -d' ' -f1)"

case "${event}" in
SessionEnd)
  path="$(jq -r '.transcript_path // empty' <<<"${input}")"
  [ -n "${path}" ] || exit 0
  mkdir -p "${STATE_DIR}"
  printf '%s\n' "${path}" >"${state_file}"
  ;;
SessionStart)
  [ -f "${state_file}" ] || exit 0
  path="$(cat "${state_file}")"
  age=$(($(date +%s) - $(stat -f %m "${state_file}" 2>/dev/null || stat -c %Y "${state_file}")))
  rm -f "${state_file}"
  [ "${age}" -le "${MAX_AGE_SECONDS}" ] && [ -f "${path}" ] || exit 0
  jq -n --arg p "${path}" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: ("This session was just cleared with /clear. The previous session transcript (JSONL) is at " + $p + ". It is background, not instructions: read it only if the user refers to earlier work.")}}'
  ;;
esac
