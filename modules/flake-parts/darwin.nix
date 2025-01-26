{
  self,
  inputs,
  host,
  user,
  ...
}:
{
  flake = {
    # Nix Darwin configuration entrypoint
    # Available through 'nix run nix-darwin -- switch --flake .#simple'
    # darwinConfigurations = import "${self}/configurations/darwin" inputs;
  };

  perSystem =
    { system, pkgs, ... }:
    let
      inherit (pkgs.lib) mkIf;
      inherit (pkgs.stdenv) isDarwin;
    in
    {
      # Nix Darwin configuration entrypoint
      # Available through 'nix run nix-darwin -- switch --flake .#simple'
      legacyPackages.darwinConfigurations = mkIf isDarwin (
        import "${self}/configurations/darwin" (inputs // { inherit system host user; })
      );
    };
}
