{pkgs, ...}: {
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
    direnv
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
    # docker  # homebrew
    # docker-builx  # homebrew
    # docker-compose  # homebrew
    # docker-credential-helper  # homebrew
    # kubectl  # homebrew
    # kubernetes-helm  # homebrew
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
}
