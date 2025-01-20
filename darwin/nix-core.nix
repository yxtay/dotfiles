{...}: {
  nix = {
    settings = {
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://cachix.cachix.org"
        "https://devenv.cachix.org"
        "https://cache.flox.dev"
        "https://numtide.cachix.org"
        "https://pre-commit-hooks.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
      ];

      trusted-users = [
        "root"
        "@admin"
      ];
    };

    # do garbage collection weekly to keep disk usage low
    gc = {
      automatic = true;
      options = "--delete-older-than 1w";
    };

    optimise = {
      automatic = true;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
}
