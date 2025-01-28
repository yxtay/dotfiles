{
  self,
  lib,
  inputs,
  host,
  user,
  ...
}:
{
  flake.darwinModules.default = import "${self}/modules/darwin";

  perSystem =
    { pkgs, ... }:
    let
      specialArgs = inputs // {
        inherit user;
      };

      configuration = {
        home-manager.users.${user.name} = self.homeModules.default;
        users.users.${user.name}.home = "/Users/${user.name}";
        imports = [ self.darwinModules.default ];
      };
    in
    {
      # Nix Darwin configuration entrypoint
      # Available through 'nix run nix-darwin -- switch --flake .#simple'
      legacyPackages.darwinConfigurations = lib.mkIf pkgs.stdenv.isDarwin {
        "${host.name}" = inputs.nix-darwin.lib.darwinSystem {
          inherit pkgs specialArgs;
          modules = [ configuration ];
        };
      };
    };
}
