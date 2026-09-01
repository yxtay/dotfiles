#!/usr/bin/env bash
# SessionStart hook: ensure codebase-memory-mcp daemon is running.
set -euo pipefail

codebase-memory-mcp daemon start >/dev/null 2>&1
