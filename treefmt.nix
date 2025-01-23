_: {
  projectRootFile = "flake.nix";

  programs = {
    deadnix.enable = true;
    prettier.enable = true;
    nixfmt.enable = true;
    shellcheck.enable = true;
    shfmt.enable = true;
    statix.enable = true;
    taplo.enable = true;
    yamlfmt.enable = true;
  };
}
