{ self, inputs, ... }:
let
  inherit (inputs) user;
in
{
  flake.homeModules.default = import "${self}/modules/home";

  perSystem =
    { pkgs, ... }:
    {
      # Standalone home-manager configuration entrypoint
      # Available through 'nix run home-manager -- switch --flake .#simple'
      legacyPackages.homeConfigurations = {
        "${user.name}" = self.nixos-unified.lib.mkHomeConfiguration pkgs {

          imports = [
            self.homeModules.default
            {
              home = {
                username = user.name;
                homeDirectory = (if pkgs.stdenv.isDarwin then "/Users/" else "/home/") + user.name;
              };
            }
          ];
        };
      };
    };
}
