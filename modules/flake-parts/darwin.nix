{
  self,
  lib,
  inputs,
  ...
}:
let
  inherit (inputs) host user;
in
{
  flake.darwinModules.default = import "${self}/modules/darwin";

  perSystem =
    { pkgs, ... }:
    {
      # Nix Darwin configuration entrypoint
      # Available through 'nix run nix-darwin -- switch --flake .#simple'
      legacyPackages.darwinConfigurations = lib.mkIf pkgs.stdenv.isDarwin {
        "${host.name}" = self.nixos-unified.lib.mkMacosSystem { home-manager = true; } {
          nixpkgs.pkgs = pkgs;

          imports = [
            self.darwinModules.default
            {
              home-manager.users.${user.name} = self.homeModules.default;
              users.users.${user.name}.home = "/Users/${user.name}";
            }
          ];
        };
      };
    };
}
