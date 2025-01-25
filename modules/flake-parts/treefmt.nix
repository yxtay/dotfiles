{ treefmt-nix, ... }:
{
  imports = [ treefmt-nix.flakeModule ];
  perSystem = {
    treefmt = {
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
    };
  };
}
