# smartcache evals

(( $+commands[brew] )) && smartcache eval brew shellenv
(( $+commands[chezmoi] )) && smartcache comp chezmoi completion zsh
(( $+commands[direnv] )) && smartcache eval direnv hook zsh
(( $+commands[fzf] )) && smartcache eval fzf --zsh
(( $+commands[mcfly] )) && smartcache eval mcfly init zsh
(( $+commands[mcfly-fzf] )) && smartcache eval mcfly-fzf init zsh
(( $+commands[mise] )) && smartcache eval mise activate zsh
(( $+commands[poetry] )) && smartcache comp poetry completions zsh
(( $+commands[ruff] )) && smartcache comp ruff generate-shell-completion zsh
(( $+commands[starship] )) && smartcache eval starship init zsh
(( $+commands[thefuck] )) && smartcache eval thefuck --alias
(( $+commands[uv] )) && smartcache comp uv generate-shell-completion zsh
(( $+commands[zoxide] )) && smartcache eval zoxide init zsh
