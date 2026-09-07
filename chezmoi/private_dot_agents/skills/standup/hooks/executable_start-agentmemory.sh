#!/usr/bin/env bash
# SessionStart hook: auto-start agentmemory server if not already running.
set -euo pipefail

if npx --yes @agentmemory/agentmemory status >/dev/null 2>&1; then
  exit 0
fi

# Kill stale process occupying the port before starting fresh.
stale_pid=$(lsof -ti :3111 2>/dev/null) && kill "$stale_pid" 2>/dev/null || true

npx -y @agentmemory/agentmemory >>"$HOME/.agentmemory/server.log" 2>&1 &
