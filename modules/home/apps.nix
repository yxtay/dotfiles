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
    bun
    cabal-install
    deno
    devbox
    direnv
    git
    gh
    ghc
    go
    llvmPackages.openmp
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
    trunk-io
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
    awscli2
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
