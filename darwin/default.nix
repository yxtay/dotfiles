{user, ...}: {
  imports = [
    ./networking.nix
    ./homebrew.nix
    ./nix-core.nix
    ./system.nix
    ./zsh.nix
  ];

  system.stateVersion = 5;

  time.timeZone = "Asia/Singapore";

  users.users = {
    "${user.name}" = {
      inherit (user) home;
    };
  };
}
