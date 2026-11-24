#!/usr/bin/env zsh
set -euo pipefail

if command -v gh >/dev/null; then
  GITHUB_TOKEN=$(gh auth token)
  export GITHUB_TOKEN
  trap 'unset GITHUB_TOKEN' EXIT
fi

# zimfw is a function loaded by zim's init.zsh, which scripts don't source
export ZIM_HOME="${XDG_CONFIG_HOME:-$HOME}/zim"
zimfw() { source "${ZIM_HOME}/zimfw.zsh" "$@"; }

chezmoi --refresh-externals apply

if [[ -e "${ZIM_HOME}/zimfw.zsh" ]]; then
  zimfw upgrade -q
  zimfw update -q
fi

if command -v uv >/dev/null; then uv tool upgrade --all; fi
if command -v npm >/dev/null; then
  npm update --global
  npx --yes skills update --global
fi
