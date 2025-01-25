inputs@{ self, ... }:
{
  flake = {
    # Standalone home-manager configuration entrypoint
    # Available through 'nix run home-manager -- switch --flake .#simple'
    # homeConfigurations = import ./configurations/home inputs;
  };

  perSystem =
    { system, ... }:
    {
      # Standalone home-manager configuration entrypoint
      # Available through 'nix run home-manager -- switch --flake .#simple'
      legacyPackages.homeConfigurations = import "${self}/configurations/home" (
        inputs // { inherit system; }
      );
    };
}
