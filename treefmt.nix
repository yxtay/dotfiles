_: {
  projectRootFile = "flake.nix";
  programs.alejandra.enable = true;
  programs.deadnix.enable = true;
  programs.prettier.enable = true;
  programs.shellcheck.enable = true;
  programs.shfmt.enable = true;
  programs.statix.enable = true;
  programs.taplo.enable = true;
}
