specialArgs@{
  self,
  nix-darwin,
  home-manager,
  determinate,
  mac-app-util,
  nix-homebrew,
  nix-index-database,
  system,
  host,
  ...
}:
{
  "${host.name}" = nix-darwin.lib.darwinSystem {
    inherit system specialArgs;

    modules = [
      determinate.darwinModules.default
      home-manager.darwinModules.home-manager
      mac-app-util.darwinModules.default
      nix-homebrew.darwinModules.nix-homebrew
      nix-index-database.darwinModules.nix-index
      "${self}/modules/darwin"
    ];
  };
}
