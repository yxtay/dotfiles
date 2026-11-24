#!/usr/bin/env zsh
set -euo pipefail

if command -v gh >/dev/null; then
  GITHUB_TOKEN=$(gh auth token)
  export GITHUB_TOKEN
  trap 'unset GITHUB_TOKEN' EXIT
fi

# zimfw is a function from zim's init.zsh, which scripts don't source; it requires ZIM_HOME
export ZIM_HOME="${XDG_CONFIG_HOME:-$HOME}/zim"

chezmoi --refresh-externals apply

if [[ -e "${ZIM_HOME}/zimfw.zsh" ]]; then
  source "${ZIM_HOME}/zimfw.zsh" upgrade -q
  source "${ZIM_HOME}/zimfw.zsh" update -q
fi

if command -v uv >/dev/null; then uv tool upgrade --all; fi
if command -v npm >/dev/null; then
  npm update --global
  npx --yes skills update --global
fi
