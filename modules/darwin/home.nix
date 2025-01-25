{
  self,
  mac-app-util,
  nix-index-database,
  specialArgs,
  user,
  ...
}:
{
  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = specialArgs;
    sharedModules = [
      mac-app-util.homeManagerModules.default
      nix-index-database.hmModules.nix-index
    ];
    users.${user.name} = import "${self}/modules/home";
  };

  users.users = {
    "${user.name}" = { inherit (user) home; };
  };
}
