inputs@{
  self,
  specialArgs,
  user,
  ...
}:
{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = specialArgs;
    sharedModules = [ ];
    users.${user.name} = import "${self}/modules/home";
  };

  users.users = {
    "${user.name}" = { inherit (user) home; };
  };
}
