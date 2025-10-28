#!/usr/bin/env bash
set -euxo pipefail

if command -v nix >/dev/null; then
  nix profile wipe-history --older-than 7d
  nix store gc
  nix store optimise
fi

if command -v uv >/dev/null; then
  uv cache prune --force
  uvx pre-commit gc
  uvx --from huggingface_hub hf cache ls --filter "accessed>4w" -q | xargs -r uvx --from huggingface_hub hf cache rm -y
fi

if command -v trunk >/dev/null; then trunk cache prune; fi

find "${HOME}/.cache/huggingface/"{datasets/,xet/} -type f -mtime +7 -delete
find "${HOME}/.cache/" -type d -empty -depth -delete
