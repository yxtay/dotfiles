inputs@{ pkgs, lib, ... }:
let
  settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nixpkgs-unfree.cachix.org"
      "https://cachix.cachix.org"
      "https://devenv.cachix.org"
      "https://cache.flox.dev"
      "https://numtide.cachix.org"
      "https://cache.flakehub.com"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    ];
    trusted-users = [
      "root"
      "@admin"
    ];
  };
in
{
  nix = {
    enable = false;
    package = lib.mkDefault inputs.nix.packages.${pkgs.system}.default;

    channel.enable = false;
    optimise.automatic = false;

    gc = {
      automatic = false;
      interval = {
        Hour = 3;
        Minute = 15;
      };
      options = "--delete-older-than 1w";
    };

    inherit settings;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.etc = {
    "determinate/config.json".text = ''
      {
        "garbageCollector": {
          "strategy": "automatic"
        }
      }
    '';

    "nix/nix.custom.conf".text = ''
      experimental-features = ${lib.concatStringsSep " " settings.experimental-features}
      extra-substituters = ${lib.concatStringsSep " " settings.extra-substituters}
      extra-trusted-public-keys = ${lib.concatStringsSep " " settings.extra-trusted-public-keys}
      trusted-users = ${lib.concatStringsSep " " settings.trusted-users}
    '';
  };
}
