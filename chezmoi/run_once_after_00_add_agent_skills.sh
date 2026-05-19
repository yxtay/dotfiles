#!/usr/bin/env bash
set -euo pipefail

if command -v npx >/dev/null; then
  skills=(
    vercel-labs/skills
    anthropics/skills
    JuliusBrussee/caveman
  )
  for entry in "${skills[@]}"; do
    npx --yes skills add "${entry}" --global --agent universal --skill "*" --yes
  done
fi
