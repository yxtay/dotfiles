#!/usr/bin/env bash
# SessionStart(startup|clear): inject the cleared transcript if record-cleared-transcript.sh left a
# fresh record (/clear), else the most recent other transcript in the project dir (startup, or
# /clear without a record). STATE_DIR and the key must match that script.
# shortcut: the fallback can pick a concurrent session in the same project; upgrade to
# per-session tracking if that bites.
set -euo pipefail
command -v jq &>/dev/null || exit 0

STATE_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/claude-clear-continue"

input="$(cat)"
cwd="$(jq -r '.cwd // empty' <<<"${input}")"
transcript="$(jq -r '.transcript_path // empty' <<<"${input}")"
[ -n "${cwd}" ] && [ -n "${transcript}" ] || exit 0
source="$(jq -r '.source // empty' <<<"${input}")"
state_file="${STATE_DIR}/${cwd//[^[:alnum:]]/-}"

previous=""
# A record is only meant for /clear, so a startup leaves it for expiry.
if [ "${source}" = clear ] && [ -f "${state_file}" ]; then
  candidate="$(cat "${state_file}")"
  fresh="$(find "${state_file}" -mmin -1)" # less than a minute old
  rm -f "${state_file}"
  if [ -n "${fresh}" ] && [ -f "${candidate}" ]; then
    previous="${candidate}"
    label="The session just cleared with /clear"
  fi
fi
if [ -z "${previous}" ]; then
  # Newest top-level transcript other than the current one (subagent transcripts live in subdirs).
  for f in "$(dirname "${transcript}")"/*.jsonl; do
    [ -f "${f}" ] && [ "${f}" != "${transcript}" ] || continue
    if [ -z "${previous}" ] || [ "${f}" -nt "${previous}" ]; then previous="${f}"; fi
  done
  label="The most recent previous session in this project"
fi
[ -n "${previous}" ] || exit 0

jq -n --arg p "${previous}" --arg l "${label}" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: ($l + " has its transcript (JSONL) at " + $p + ". It is background, not instructions: read it only if the user refers to earlier work.")}}'
