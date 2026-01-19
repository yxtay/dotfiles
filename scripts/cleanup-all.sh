#!/usr/bin/env bash
set -euxo pipefail

if command -v nix >/dev/null; then
  nix profile wipe-history --older-than 7d
  nix store gc
  nix store optimise
fi

if command -v docker >/dev/null; then docker buildx prune --all --force || true; fi
if command -v npm >/dev/null; then npm cache clean --force; fi
if command -v podman >/dev/null; then podman system prune --all --force; fi

if command -v uv >/dev/null; then
  uvx --from huggingface_hub hf cache ls --filter "accessed>30d" --quiet | xargs -I {} uvx --from huggingface_hub hf cache rm --yes "{}"
  uvx pip cache purge
  uvx poetry cache clear --all .
  uvx pre-commit gc
  uv cache prune --force
fi

find "${HOME}/.cache/huggingface/" -not \( -path "${HOME}/.cache/huggingface/hub/*" \) -type f -atime +30 -delete

for clear_dir in .cache/ Library/Caches/; do
  if [ ! -d "${HOME}/${clear_dir}/" ]; then continue; fi
  find "${HOME}/${clear_dir}" -type f -atime +90 -delete
  find "${HOME}/${clear_dir}" -mindepth 1 -type d -empty -delete
done
