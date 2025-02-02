inputs@{ pkgs, ... }:
{
  imports = [ inputs.mac-app-util.homeManagerModules.default ];

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
    cabal-install
    devbox
    direnv
    git
    gh
    go
    mise
    ollama
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
    docker-compose
    docker-credential-helpers
    # kubectl  # homebrew
    kubernetes-helm
    # podman  # homebrew

    # python
    cookiecutter
    pre-commit
    pyright

    # work
    awscli
    azure-cli
    codefresh
    databricks-cli
    google-cloud-sdk
  ];

  programs.java = {
    enable = true;
    package = pkgs.zulu8;
  };
}
