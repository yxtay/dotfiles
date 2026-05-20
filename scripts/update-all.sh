#!/usr/bin/env bash
set -euo pipefail

GITHUB_TOKEN=$(gh auth token)
export GITHUB_TOKEN
trap 'unset GITHUB_TOKEN' EXIT

chezmoi --refresh-externals apply
