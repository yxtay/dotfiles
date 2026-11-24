#!/usr/bin/env bash
set -euo pipefail

if command -v gh >/dev/null; then
  GITHUB_TOKEN=$(gh auth token)
  export GITHUB_TOKEN
  trap 'unset GITHUB_TOKEN' EXIT
fi

chezmoi --refresh-externals apply

# zimfw is a zsh function, so run it via its script; update also rebuilds init.zsh
zim_home="${XDG_CONFIG_HOME:-$HOME}/zim"
if command -v zsh >/dev/null && [[ -e "${zim_home}/zimfw.zsh" ]]; then
  ZIM_HOME="${zim_home}" zsh -c 'source "$ZIM_HOME/zimfw.zsh" "$@"' _ upgrade -q
  ZIM_HOME="${zim_home}" zsh -c 'source "$ZIM_HOME/zimfw.zsh" "$@"' _ update -q
fi

if command -v uv >/dev/null; then uv tool upgrade --all; fi
if command -v npm >/dev/null; then
  npm update --global
  npx --yes skills update --global
fi
