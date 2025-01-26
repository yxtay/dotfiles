{
  self,
  inputs,
  lib,
  host,
  ...
}:
{
  flake = {
    # Nix Darwin configuration entrypoint
    # Available through 'nix run nix-darwin -- switch --flake .#simple'
    # darwinConfigurations = import "${self}/configurations/darwin" inputs;
  };

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
      legacyPackages.darwinConfigurations = lib.mkIf pkgs.stdenv.isDarwin (
        import "${self}/configurations/darwin" (inputs // { inherit system host user; })
      );
    };
}
