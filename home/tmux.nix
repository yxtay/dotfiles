{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    prefix = "C-space";
    sensibleOnTop = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";

    tmuxinator.enable = true;
    tmuxp.enable = true;

    plugins = with pkgs.tmuxPlugins; [
      battery
      continuum
      copycat
      cpu
      dracula
      fpp
      logging
      open
      online-status
      pain-control
      prefix-highlight
      resurrect
      sensible
      sessionist
      sidebar
      urlview
      vim-tmux-focus-events
      vim-tmux-navigator
      yank
    ];
  };
}
