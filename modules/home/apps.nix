{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # terminals & editors
    helix
    micro
    nano
    neovim
    tmux
    vim
    zsh

    # dev
    ansible
    bun
    cabal-install
    deno
    devbox
    direnv
    git
    gh
    ghc
    glab
    go
    mise
    nodejs_22
    ollama
    pnpm
    process-compose
    python3
    ruby
    rustup
    terraform
    terragrunt
    unison
    usage

    # container
    colima
    docker
    docker-buildx
    docker-compose
    docker-credential-helpers
    # kind
    kubectl
    # kubernetes-helm
    # podman
    # podman-compose

    # work
    awscli2
    azure-cli
    databricks-cli
    google-cloud-sdk

    # ai
    claude-code
    gemini-cli
    qwen-code
  ];

  programs.java = {
    enable = true;
    package = pkgs.zulu8;
  };
}
