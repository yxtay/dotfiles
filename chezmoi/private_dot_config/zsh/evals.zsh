#!/usr/bin/env zsh

# smartcache

typeset -A comps=(
   chezmoi "chezmoi completion zsh"
   codefresh "codefresh completion zsh"
   databricks "databricks completion zsh"
   delta "delta --generate-completion zsh"
   docker "docker completion zsh"
   fd "fd --gen-completions zsh"
   gh "gh completion -s zsh"
   git-lfs "git-lfs completion zsh"
   helm "helm completion zsh"
   kind "kind completion zsh"
   kubectl "kubectl completion zsh"
   mise "mise completion zsh"
   pip "pip completion --zsh"
   podman "podman completion zsh"
   poetry "poetry completions zsh"
   rg "rg --generate complete-zsh"
   ruff "ruff generate-shell-completion zsh"
   rustup "rustup completions zsh"
   uv "uv generate-shell-completion zsh"
   uvx "uvx --generate-shell-completion zsh"
   wezterm "wezterm shell-completion --shell zsh"
)

typeset -A evals=(
   direnv "direnv hook zsh"
   fzf "fzf --zsh"
   mcfly "mcfly init zsh"
   mise "mise activate zsh"
   starship "starship init zsh"
   thefuck "thefuck --alias"
   zoxide "zoxide init zsh"
)

# delete smartcache files older than 30 days
cache_dir=${XDG_CACHE_HOME}/zsh-smartcache
[[ -d "${cache_dir}" ]] && find "${cache_dir}" -type f -mtime +30 -delete || true
for name cmd ("${(@kv)comps}") (( $+commands[${name}] )) && smartcache comp ${(z)cmd} || true
for name cmd ("${(@kv)evals}") (( $+commands[${name}] )) && smartcache eval ${(z)cmd} || true

# brew shellenv changes depending whether it has been evaluated previously
(( $+commands[brew] )) && eval $(brew shellenv) || true
# mcfly-fzf must be after mcfly
(( $+commands[mcfly-fzf] )) && smartcache eval mcfly-fzf init zsh || true

# zcompile smartcache for subsequent speedup
for cache in ${cache_dir}/*; do
    if [[ -s "${cache}" && ! "${cache}.zwc" -nt "${cache}" ]]; then
        zcompile "${cache}" &!
    fi
done
