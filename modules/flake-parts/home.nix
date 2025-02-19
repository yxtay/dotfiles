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
      homeConfiguration = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = inputs;
        modules = [ self.homeModules.default ];
      };
    in
    {
      # Standalone home-manager configuration entrypoint
      # Available through 'nix run home-manager -- switch --flake .#simple'
      legacyPackages.homeConfigurations = {
        "${user.name}" = homeConfiguration;
        "runner" = homeConfiguration;
      };
    };
}
