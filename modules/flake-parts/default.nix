{ systems, ... }:
{
  systems = import systems;
  imports = [
    ./darwin.nix
    ./git-hooks.nix
    ./home.nix
    ./treefmt.nix
  ];
}
