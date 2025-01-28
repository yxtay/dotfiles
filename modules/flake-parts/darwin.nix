{
  self,
  lib,
  inputs,
  host,
  ...
}:
{
  flake.darwinModules.default = import "${self}/modules/darwin";

  perSystem =
    {
      system,
      pkgs,
      user,
      ...
    }:
    {
      # Nix Darwin configuration entrypoint
      # Available through 'nix run nix-darwin -- switch --flake .#simple'
      legacyPackages.darwinConfigurations = lib.mkIf pkgs.stdenv.isDarwin {
        "${host.name}" = inputs.nix-darwin.lib.darwinSystem {
          inherit system;

          specialArgs = inputs // {
            inherit host user;
          };

          modules = [
            self.darwinModules.default
            {
              home-manager.users.${user.name} = self.homeModules.default;
              users.users.${user.name} = { inherit (user) home; };
            }
          ];
        };
      };
    };
}
