#!/usr/bin/env bash
set -euo pipefail

if command -v gh >/dev/null; then
  GITHUB_TOKEN=$(gh auth token)
  export GITHUB_TOKEN
  trap 'unset GITHUB_TOKEN' EXIT
fi

chezmoi --refresh-externals apply

if command -v uv >/dev/null; then uv tool upgrade --all; fi
if command -v mise >/dev/null; then mise upgrade; fi
if command -v npm >/dev/null; then
  npm update --global
  npx --yes skills update --global
fi
