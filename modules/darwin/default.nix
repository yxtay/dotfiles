inputs: {
  imports = [
    inputs.mac-app-util.darwinModules.default
    ./networking.nix
    ./home.nix
    ./homebrew.nix
    ./keyboard.nix
    ./nix-core.nix
    ./system.nix
    ./zsh.nix
  ];

  system.stateVersion = 5;

  time.timeZone = "Asia/Singapore";
}
