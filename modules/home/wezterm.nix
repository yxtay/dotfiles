_: {
  # home.packages = [pkgs.wezterm];

  programs = {
    wezterm = {
      enable = false;

      extraConfig = ''
        return {
          color_scheme = "Dracula (Official)",
          font = wezterm.font "FiraCode Nerd Font",
          front_end = "WebGpu",
          tab_bar_at_bottom = true,
          window_close_confirmation = "NeverPrompt",
          window_decorations = "RESIZE",
        }
      '';
    };
  };

  # xdg.configFile."wezterm/wezterm.lua".text = lib.concatLines [
  #   ''local wezterm = require "wezterm"''
  #   config.programs.wezterm.extraConfig
  # ];
}
