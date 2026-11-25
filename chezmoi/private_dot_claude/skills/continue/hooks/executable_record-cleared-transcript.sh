#!/usr/bin/env bash
# SessionEnd(clear): record the cleared session's transcript path, keyed by cwd, for
# inject-previous-transcript.sh. STATE_DIR and the key must match that script.
set -euo pipefail
command -v jq &>/dev/null || exit 0

STATE_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/claude-clear-continue"

input="$(cat)"
cwd="$(jq -r '.cwd // empty' <<<"${input}")"
transcript="$(jq -r '.transcript_path // empty' <<<"${input}")"
[ -n "${cwd}" ] && [ -n "${transcript}" ] || exit 0

mkdir -p "${STATE_DIR}"
printf '%s\n' "${transcript}" >"${STATE_DIR}/${cwd//[^[:alnum:]]/-}"
