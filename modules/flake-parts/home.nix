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
      legacyPackages.homeConfigurations = import "${self}/configurations/home" (
        inputs // { inherit pkgs user; }
      );
    };
}
