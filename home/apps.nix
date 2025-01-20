{pkgs, flox, ...}: {
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
    devbox
    direnv
    flox
    git
    gh
    mise
    nix-direnv
    ollama
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
    # poetry
    pre-commit
    pyright
    # ruff
    # uv

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
