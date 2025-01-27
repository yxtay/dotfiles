{ inputs, ... }:
{
  imports = [ inputs.git-hooks-nix.flakeModule ];

  perSystem = _: {
    pre-commit.settings = {
      hooks = {
        deadnix.enable = true;
        editorconfig-checker.enable = true;
        nixfmt-rfc-style.enable = true;
        statix.enable = true;
        taplo.enable = true;
        yamlfmt.enable = true;
      };
    };
  };
}
