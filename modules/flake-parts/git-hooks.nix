{ git-hooks-nix, ... }:
{
  imports = [ git-hooks-nix.flakeModule ];
  perSystem = {
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
