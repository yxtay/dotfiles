#!/usr/bin/env bash
# SessionStart hook: auto-start agentmemory server if not already running.
set -euo pipefail

if npx --yes @agentmemory/agentmemory status >/dev/null 2>&1; then
  exit 0
fi
npx -y @agentmemory/agentmemory >>"$HOME/.agentmemory/server.log" 2>&1 &
