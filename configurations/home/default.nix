extraSpecialArgs@{
  self,
  home-manager,
  mac-app-util,
  nix-index-database,
  pkgs,
  user,
  ...
}:
{
  "${user.name}" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs extraSpecialArgs;

    modules = [
      mac-app-util.homeManagerModules.default
      nix-index-database.hmModules.nix-index
      "${self}/modules/home"
    ];
  };
}
