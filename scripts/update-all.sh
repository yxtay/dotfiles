#!/usr/bin/env bash
set -euo pipefail

GITHUB_TOKEN=$(gh auth token)
sudo nix --option extra-access-tokens "github.com=${GITHUB_TOKEN}" run nix-darwin -- switch --flake .
GITHUB_TOKEN=${GITHUB_TOKEN} chezmoi --refresh-externals apply
uv tool upgrade --all
