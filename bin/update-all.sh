#!/usr/bin/env bash
set -euo pipefail

GITHUB_TOKEN=$(gh auth token)
export GITHUB_TOKEN
trap 'unset GITHUB_TOKEN' EXIT

chezmoi --refresh-externals apply
if command -v mise >/dev/null; then mise upgrade; fi
if command -v npm >/dev/null; then npm update --global; fi
if command -v uv >/dev/null; then uv tool upgrade --all; fi
