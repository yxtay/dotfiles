{
  pkgs,
  lib,
  config,
  user,
  ...
}:
{
  # import sub modules
  imports = [
    ./apps.nix
    ./chezmoi.nix
    ./editorconfig.nix
    ./git.nix
    ./gnu.nix
    ./helix.nix
    ./nix-index.nix
    ./sh.nix
    ./wezterm.nix
    ./zsh.nix
  ];

  nix.package = lib.mkDefault pkgs.nix;
  nixpkgs.config.allowUnfree = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    username = user.name;
    homeDirectory = user.home;
    sessionPath = [ "${user.home}/.local/bin" ];

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "24.11";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  xdg.enable = true;
}
