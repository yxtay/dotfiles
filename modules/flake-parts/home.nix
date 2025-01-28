{
  self,
  inputs,
  user,
  ...
}:
{
  flake.homeModules.default = import "${self}/modules/home";

  perSystem =
    { pkgs, ... }:
    let
      extraSpecialArgs = inputs // {
        inherit user;
      };

      configuration = {
        home.username = user.name;
        home.homeDirectory = (if pkgs.stdenv.isDarwin then "/Users/" else "/home/") + user.name;
        imports = [ self.homeModules.default ];
      };
    in
    {
      # Standalone home-manager configuration entrypoint
      # Available through 'nix run home-manager -- switch --flake .#simple'
      legacyPackages.homeConfigurations = {
        "${user.name}" = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs extraSpecialArgs;
          modules = [ configuration ];
        };
      };
    };
}
