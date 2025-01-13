# smartcache

typeset -A comps=(
   chezmoi "chezmoi completion zsh"
   codefresh "codefresh completion zsh"
   databricks "databricks completion zsh"
   delta "delta --generate-completion zsh"
   docker "docker completion zsh"
   fd "fd --gen-completions zsh"
   gh "gh completion -s zsh"
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
   wezterm "wezterm shell-completion --shell zsh"
)

typeset -A evals=(
   direnv "direnv hook zsh"
   fzf "fzf --zsh"
   mcfly "mcfly init zsh"
   mcfly-fzf "mcfly-fzf init zsh"
   mise "mise activate zsh"
   starship "starship init zsh"
   thefuck "thefuck --alias"
   zoxide "zoxide init zsh"
)

# delete smartcache files older than 30 days
find ${XDG_CACHE_HOME}/zsh-smartcache/ -type f -mtime +30 -delete
for name cmd ("${(@kv)comps}") (( $+commands[${name}] )) && smartcache comp ${(z)cmd}
for name cmd ("${(@kv)evals}") (( $+commands[${name}] )) && smartcache eval ${(z)cmd}

# brew shellenv changes depending whether it has been evaluated previously
(( $+commands[brew] )) && eval $(brew shellenv)
