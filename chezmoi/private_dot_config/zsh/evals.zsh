# smartcache evals

(( $+commands[brew] )) && smartcache eval brew shellenv
(( $+commands[chezmoi] )) && smartcache comp chezmoi completion zsh
(( $+commands[codefresh] )) && smartcache comp codefresh completion zsh
(( $+commands[databricks] )) && smartcache comp databricks completion zsh
(( $+commands[delta] )) && smartcache comp delta --generate-completion zsh
(( $+commands[direnv] )) && smartcache eval direnv hook zsh
(( $+commands[docker] )) && smartcache comp docker completion zsh
(( $+commands[fd] )) && smartcache comp fd --gen-completions zsh
(( $+commands[fzf] )) && smartcache eval fzf --zsh
(( $+commands[helm] )) && smartcache comp helm completion zsh
(( $+commands[kind] )) && smartcache comp kind completion zsh
(( $+commands[kubectl] )) && smartcache comp kubectl completion zsh
(( $+commands[mcfly] )) && smartcache eval mcfly init zsh
(( $+commands[mcfly-fzf] )) && smartcache eval mcfly-fzf init zsh
(( $+commands[mise] )) && smartcache comp mise completion zsh
(( $+commands[mise] )) && smartcache eval mise activate zsh
(( $+commands[podman] )) && smartcache comp podman completion zsh
(( $+commands[poetry] )) && smartcache comp poetry completions zsh
(( $+commands[rg] )) && smartcache comp rg --generate complete-zsh
(( $+commands[ruff] )) && smartcache comp ruff generate-shell-completion zsh
(( $+commands[rustup] )) && smartcache comp rustup completions zsh
(( $+commands[starship] )) && smartcache eval starship init zsh
(( $+commands[thefuck] )) && smartcache eval thefuck --alias
(( $+commands[uv] )) && smartcache comp uv generate-shell-completion zsh
(( $+commands[wezterm] )) && smartcache comp wezterm shell-completion --shell zsh
(( $+commands[zoxide] )) && smartcache eval zoxide init zsh
