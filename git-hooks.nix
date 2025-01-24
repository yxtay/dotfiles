_: {
  src = ./.;

  hooks = {
    deadnix.enable = true;
    editorconfig-checker.enable = true;
    nixfmt-rfc-style.enable = true;
    statix.enable = true;
    taplo.enable = true;
    yamlfmt.enable = true;
  };
}
