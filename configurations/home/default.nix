{
  self,
  nixpkgs,
  home-manager,
  mac-app-util,
  nix-index-database,
  specialArgs,
  system,
  user,
  ...
}:
{
  "${user.name}" = home-manager.lib.homeManagerConfiguration {
    pkgs = import nixpkgs { inherit system; };
    extraSpecialArgs = specialArgs;

    modules = [
      mac-app-util.homeManagerModules.default
      nix-index-database.hmModules.nix-index
      "${self}/modules/home"
    ];
  };
}
