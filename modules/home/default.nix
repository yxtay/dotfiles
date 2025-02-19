{ ... }:
{
  # import sub modules
  imports = [
    ./apps.nix
    ./chezmoi.nix
    ./editorconfig.nix
    ./git.nix
    ./gnu.nix
    ./helix.nix
    ./nix-core.nix
    ./sh.nix
    ./wezterm.nix
    ./zsh.nix
  ];

  home = {
    sessionPath = [ "$HOME/.local/bin" ];

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
