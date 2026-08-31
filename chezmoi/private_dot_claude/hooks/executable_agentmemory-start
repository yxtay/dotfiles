#!/bin/sh
pid_file="$HOME/.agentmemory/iii.pid"
if [ -f "$pid_file" ] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
  exit 0
fi
nohup npx -y @agentmemory/agentmemory >>"$HOME/.agentmemory/server.log" 2>&1 &
disown
