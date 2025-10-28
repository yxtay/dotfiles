#!/usr/bin/env bash
set -euxo pipefail

if command -v nix >/dev/null; then
  nix profile wipe-history --older-than 7d
  nix store gc
  nix store optimise
fi

if command -v uv >/dev/null; then
  uv cache prune --force
  uvx --from huggingface_hub hf cache ls --filter "accessed>4w" -q | xargs -r uvx --from huggingface_hub hf cache rm -y
  uvx pip cache purge
  uvx poetry cache clear --all .
  uvx pre-commit gc
fi

if command -v npm >/dev/null; then npm cache clean --force; fi
if command -v trunk >/dev/null; then trunk cache prune; fi

find "${HOME}/.cache/huggingface/" -not \( -path "${HOME}/.cache/huggingface/hub/*" \) -type f -mtime +7 -delete
find "${HOME}/.cache/" -type d -empty -delete
