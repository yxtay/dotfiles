#!/usr/bin/env bash
# SessionStart hook: auto-start agentmemory server if not already running,
# then backfill JSONL transcripts.
set -euo pipefail

am_dir="$HOME/.agentmemory"
log_file="$am_dir/server.log"
lock_dir="$am_dir/import.lock"
marker="$am_dir/last-import"

# /livez is unauthenticated, so a missing or rotated bearer secret (agentmemory >=0.9.30
# auto-generates one) can never make a healthy server look dead and get it killed.
healthy() {
  curl -sf --max-time 5 "http://localhost:3111/agentmemory/livez" >/dev/null 2>&1
}

# import-jsonl is additive: re-importing a transcript duplicates its observations.
# So only import transcripts modified since the last run, one importer at a time.
import_jsonl() {
  # mkdir is atomic (macOS has no flock); a lock whose owner died is reclaimed.
  if ! mkdir "$lock_dir" 2>/dev/null; then
    kill -0 "$(cat "$lock_dir/pid" 2>/dev/null)" 2>/dev/null && return 0
    rm -rf "$lock_dir"
    mkdir "$lock_dir" 2>/dev/null || return 0
  fi
  echo $$ >"$lock_dir/pid"
  trap 'rm -rf "$lock_dir"' EXIT

  local since=(-mtime -7) next
  [ -f "$marker" ] && since=(-newer "$marker")
  next=$(mktemp "$am_dir/last-import.XXXXXX")

  find "$HOME/.claude/projects" -name "*.jsonl" "${since[@]}" -not -path "*/subagents/*" -print 2>/dev/null |
    while IFS= read -r f; do
      grep -qF '"type":"assistant"' "$f" || continue
      # A failed import must be retried next run, so keep the marker where it was.
      npx -y @agentmemory/agentmemory import-jsonl "$f" >>"$log_file" 2>&1 || rm -f "$next"
    done
  [ -f "$next" ] && mv "$next" "$marker" || rm -f "$next"
}

# Detached from the hook's stdio so a slow import can never hold the session start open.
backfill() {
  import_jsonl >/dev/null 2>&1 </dev/null &
}

if healthy; then
  backfill
  exit 0
fi

# Trim log to last 1000 lines to prevent unbounded growth.
[ -f "$log_file" ] && tail -n 1000 "$log_file" >"${log_file}.tmp" && mv "${log_file}.tmp" "$log_file"

# Kill stale process occupying the port before starting fresh.
stale_pid=$(lsof -ti :3111 2>/dev/null) && kill -9 $stale_pid 2>/dev/null || true
# Also reap orphaned agentmemory/iii processes that no longer hold the port.
pkill -f "@agentmemory/agentmemory|bin/agentmemory|\.agentmemory/bin/iii" 2>/dev/null || true

# Wait for port to actually free (up to 5s) before binding a new process.
for _ in 1 2 3 4 5; do
  lsof -ti :3111 >/dev/null 2>&1 || break
  sleep 1
done

# Unset ANTHROPIC_MODEL so agentmemory reads the correct model from ~/.agentmemory/.env
# rather than inheriting Claude Code's internal model alias (e.g. opusplan)
unset ANTHROPIC_MODEL
npx -y @agentmemory/agentmemory >>"$log_file" 2>&1 &

# Wait for server to become ready (up to 30s), then backfill.
for _ in $(seq 1 15); do
  sleep 2
  if healthy; then
    backfill
    exit 0
  fi
done
echo "--- port 3111 status ---" >&2
lsof -ti :3111 2>/dev/null | xargs -I{} echo "  PID {} still on port 3111" >&2 || echo "  port 3111 is free" >&2
echo "--- last 20 lines of $log_file ---" >&2
tail -20 "$log_file" 2>/dev/null >&2 || echo "  (no log file)" >&2
exit 1
