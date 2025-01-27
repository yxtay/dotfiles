{
  self,
  inputs,
  lib,
  host,
  ...
}:
{
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
