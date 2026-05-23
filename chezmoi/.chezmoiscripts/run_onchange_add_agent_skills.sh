#!/usr/bin/env bash
set -euo pipefail

if ! command -v npx >/dev/null; then
  exit
fi

agents=(
  antigravity
  opencode
)
agent_opt=("${agents[@]/#/--agent }")

skills=(
  vercel-labs/skills
)
for entry in "${skills[@]}"; do
  npx --yes skills add "${entry}" --global "${agent_opt[@]}" --skill "*" --yes
done
