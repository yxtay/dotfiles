inputs@{ specialArgs, ... }:
{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  home-manager = {
    backupFileExtension = "backup";
    useUserPackages = true;
    extraSpecialArgs = specialArgs;
  };
}
