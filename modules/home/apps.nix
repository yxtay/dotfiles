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
    usage

    # container
    docker
    docker-buildx
    # docker-compose  # homebrew
    docker-credential-helpers
    # kind  # homebrew
    # kubectl  # homebrew
    kubernetes-helm
    # podman  # homebrew
    # podman-compose  # homebrew

    # python
    cookiecutter
    pre-commit
    pyright

    # work
    awscli2
    azure-cli
    databricks-cli
    google-cloud-sdk
  ];

  programs.java = {
    enable = true;
    package = pkgs.zulu8;
  };
}
