#!/usr/bin/env zsh
set -euxo pipefail

# zimfw is a function from zim's init.zsh, which scripts don't source; it requires ZIM_HOME
export ZIM_HOME="${XDG_CONFIG_HOME:-$HOME}/zim"

if command -v colima >/dev/null; then colima prune --all --force || true; fi
if command -v docker >/dev/null; then docker buildx prune --all --force || true; fi
if command -v mise >/dev/null; then mise cache prune; fi
if command -v npm >/dev/null; then npm cache clean --force; fi
if command -v podman >/dev/null; then podman system prune --all --force; fi
if [[ -e "${ZIM_HOME}/zimfw.zsh" ]]; then source "${ZIM_HOME}/zimfw.zsh" clean; fi

if command -v uv >/dev/null; then
  uvx --from huggingface_hub hf cache ls --filter "accessed>30d" --quiet | xargs -I {} uvx --from huggingface_hub hf cache rm --yes "{}"
  uvx pip cache purge
  uvx pre-commit gc
  uv cache prune --force
fi

find "${HOME}/.cache/huggingface/" -not \( -path "${HOME}/.cache/huggingface/hub/*" \) -type f -atime +30 -delete

for clear_dir in .cache/ Library/Caches/; do
  if [ ! -d "${HOME}/${clear_dir}/" ]; then continue; fi
  find "${HOME}/${clear_dir}" -type f -atime +90 -delete || true
  find "${HOME}/${clear_dir}" -mindepth 1 -type d -empty -delete || true
done
