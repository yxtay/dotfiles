inputs@{ self, ... }:
{
  flake = {
    # Nix Darwin configuration entrypoint
    # Available through 'nix run nix-darwin -- switch --flake .#simple'
    # darwinConfigurations = import "${self}/configurations/darwin" inputs;
  };

  perSystem =
    { system, ... }:
    {
      # Standalone home-manager configuration entrypoint
      # Available through 'nix run home-manager -- switch --flake .#simple'
      legacyPackages.darwinConfigurations = import "${self}/configurations/darwin" (
        inputs // { inherit system; }
      );
    };
}
