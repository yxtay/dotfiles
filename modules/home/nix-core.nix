{
  pkgs,
  lib,
  flake,
  ...
}:
let
  inherit (flake) inputs;
in
{
  imports = [ inputs.nix-index-database.hmModules.nix-index ];

  nix = {
    package = lib.mkDefault inputs.nix.packages.${pkgs.system}.default;

    gc = {
      automatic = true;
      frequency = "daily";
      options = "--delete-older-than 1w";
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    nix-index = {
      enable = true;
      symlinkToCacheHome = true;
    };
    nix-index-database.comma.enable = true;
  };
}
