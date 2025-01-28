{ flake, ... }:
let
  inherit (flake) inputs;
in
{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit flake; };
  };
}
