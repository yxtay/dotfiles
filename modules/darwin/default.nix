_: {
  imports = [
    ./networking.nix
    ./home.nix
    ./homebrew.nix
    ./nix-core.nix
    ./system.nix
    ./zsh.nix
  ];

  system.stateVersion = 5;

  time.timeZone = "Asia/Singapore";
}
