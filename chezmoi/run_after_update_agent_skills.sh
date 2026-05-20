#!/usr/bin/env bash
set -euo pipefail

if command -v npx >/dev/null; then
  npx --yes skills update --global
fi
