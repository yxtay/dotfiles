#!/usr/bin/env bash
set -euo pipefail

trap 'unset GITHUB_TOKEN' EXIT
GITHUB_TOKEN=$(gh auth token)
export GITHUB_TOKEN

# pass secret as shell args to prevent leakage in ps aux
sudo sh -c 'nix --option extra-access-tokens "github.com=${1}" run nix-darwin -- switch --flake .' sh "${GITHUB_TOKEN}"
chezmoi --refresh-externals apply
uv tool upgrade --all
