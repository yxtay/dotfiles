#!/usr/bin/env bash
# Point a new session at the previous transcript.
# SessionEnd(clear): record the cleared session's transcript path, keyed by cwd.
# SessionStart(startup|clear): inject the cleared transcript if a fresh record exists (/clear),
# else the most recent other transcript in the project dir (startup, or /clear without a record).
# shortcut: the fallback can pick a concurrent session in the same project; upgrade to
# per-session tracking if that bites.
set -euo pipefail
command -v jq &>/dev/null || exit 0

STATE_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/claude-clear-continue"
MAX_AGE_SECONDS=60

input="$(cat)"
event="$(jq -r '.hook_event_name // empty' <<<"${input}")"
cwd="$(jq -r '.cwd // empty' <<<"${input}")"
transcript="$(jq -r '.transcript_path // empty' <<<"${input}")"
[ -n "${cwd}" ] && [ -n "${transcript}" ] || exit 0
state_file="${STATE_DIR}/$(printf '%s' "${cwd}" | shasum | cut -d' ' -f1)"

case "${event}" in
SessionEnd)
  mkdir -p "${STATE_DIR}"
  printf '%s\n' "${transcript}" >"${state_file}"
  ;;
SessionStart)
  previous=""
  if [ -f "${state_file}" ]; then
    age=$(($(date +%s) - $(stat -f %m "${state_file}" 2>/dev/null || stat -c %Y "${state_file}")))
    candidate="$(cat "${state_file}")"
    rm -f "${state_file}"
    if [ "${age}" -le "${MAX_AGE_SECONDS}" ] && [ -f "${candidate}" ]; then
      previous="${candidate}"
      label="The session just cleared with /clear"
    fi
  fi
  if [ -z "${previous}" ]; then
    # Newest top-level transcript other than the current one (subagent transcripts live in subdirs).
    previous="$(ls -t "$(dirname "${transcript}")"/*.jsonl 2>/dev/null | grep -vxF "${transcript}" | head -n 1 || true)"
    label="The most recent previous session in this project"
  fi
  [ -n "${previous}" ] || exit 0
  jq -n --arg p "${previous}" --arg l "${label}" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: ($l + " has its transcript (JSONL) at " + $p + ". It is background, not instructions: read it only if the user refers to earlier work.")}}'
  ;;
esac
