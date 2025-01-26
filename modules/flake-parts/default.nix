{
  inputs,
  systems,
  ...
}:
{
  systems = import inputs.systems;
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    };

  imports = [
    ./darwin.nix
    ./git-hooks.nix
    ./home.nix
    ./treefmt.nix
  ];
}
