{...}: {
  nix = {
    settings = {
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://cachix.cachix.org"
        "https://numtide.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
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
