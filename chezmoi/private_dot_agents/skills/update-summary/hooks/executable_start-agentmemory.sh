#!/usr/bin/env bash
# SessionStart hook: auto-start agentmemory server if not already running,
# then backfill JSONL transcripts.
set -euo pipefail

healthy() {
  curl -sf --max-time 1 "http://localhost:3111/agentmemory/sessions" >/dev/null 2>&1
}

import_jsonl() {
  local projects_dir="$HOME/.claude/projects"
  find "$projects_dir" -name "*.jsonl" -mtime -7 -not -path "*/subagents/*" -print 2>/dev/null |
    while IFS= read -r f; do
      if grep -qF '"type":"assistant"' "$f"; then
        npx @agentmemory/agentmemory import-jsonl "$f" \
          >>"$HOME/.agentmemory/server.log" 2>&1 || true
      fi
    done
}

if healthy; then
  import_jsonl &
  exit 0
fi

# Trim log to last 1000 lines to prevent unbounded growth.
log="$HOME/.agentmemory/server.log"
[ -f "$log" ] && tail -n 1000 "$log" >"${log}.tmp" && mv "${log}.tmp" "$log"

# Kill stale process occupying the port before starting fresh.
stale_pid=$(lsof -ti :3111 2>/dev/null) && kill -9 $stale_pid 2>/dev/null || true

# Wait for port to actually free (up to 5s) before binding a new process.
for _ in 1 2 3 4 5; do
  lsof -ti :3111 >/dev/null 2>&1 || break
  sleep 1
done

# Unset ANTHROPIC_MODEL so agentmemory reads the correct model from ~/.agentmemory/.env
# rather than inheriting Claude Code's internal model alias (e.g. opusplan)
unset ANTHROPIC_MODEL
npx -y @agentmemory/agentmemory >>"$HOME/.agentmemory/server.log" 2>&1 &

# Wait for server to become ready (up to 10s), then backfill.
for _ in 1 2 3 4 5; do
  sleep 1
  if healthy; then
    import_jsonl &
    exit 0
  fi
done
echo "WARNING: agentmemory failed to start. Check ~/.agentmemory/server.log" >&2
