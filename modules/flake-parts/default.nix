{
  inputs,
  user,
  ...
}:
{
  systems = import inputs.systems;
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      _module.args = {
        inherit pkgs;
        user = user // {
          home = (if pkgs.stdenv.isDarwin then "/Users/" else "/home/") + user.name;
        };
      };
    };

  imports = [
    ./darwin.nix
    ./git-hooks.nix
    ./home.nix
    ./treefmt.nix
  ];
}
