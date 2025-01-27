{
  self,
  inputs,
  ...
}:
{
  perSystem =
    { pkgs, user, ... }:
    {
      # Standalone home-manager configuration entrypoint
      # Available through 'nix run home-manager -- switch --flake .#simple'
      legacyPackages.homeConfigurations = {
        "${user.name}" = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = inputs // {
            inherit user;
          };

          modules = [ "${self}/modules/home" ];
        };
      };
    };
}
