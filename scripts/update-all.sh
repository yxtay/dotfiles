#!/usr/bin/env bash
set -euo pipefail

trap 'unset GITHUB_TOKEN' EXIT

GITHUB_TOKEN=$(gh auth token)
export GITHUB_TOKEN

sudo nix --option extra-access-tokens "github.com=${GITHUB_TOKEN}" run nix-darwin -- switch --flake .
chezmoi --refresh-externals apply
uv tool upgrade --all
