_: {
  projectRootFile = "flake.nix";

  programs = {
    alejandra.enable = true;
    deadnix.enable = true;
    prettier.enable = true;
    shellcheck.enable = true;
    shfmt.enable = true;
    statix.enable = true;
    taplo.enable = true;
  };
}
