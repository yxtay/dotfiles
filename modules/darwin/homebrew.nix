{
  lib,
  config,
  user,
  ...
}:
{
  # https://github.com/zhaofengli/nix-homebrew/issues/3
  system.activationScripts.extraUserActivation.text = lib.mkOrder 1501 (
    lib.concatLines (
      lib.mapAttrsToList (
        prefix: d:
        if d.enable then
          ''
            sudo chown -R ${config.nix-homebrew.user} ${prefix}/bin
            sudo chgrp -R ${config.nix-homebrew.group} ${prefix}/bin
          ''
        else
          ""
      ) config.nix-homebrew.prefixes
    )
  );

  # https://github.com/zhaofengli/nix-homebrew
  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;
    enableZshIntegration = false;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = config.system == "aarch64-darwin";

    # User owning the Homebrew prefix
    user = user.name;

    # Optional: Declarative tap management
    # taps = {
    # };

    # Optional: Enable fully-declarative tap management
    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
    mutableTaps = true;

    # Automatically migrate existing Homebrew installations
    autoMigrate = true;
  };

  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true; # Fetch the newest stable branch of Homebrew's git repo
      upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
      # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
      cleanup = "zap";
    };

    # https://github.com/zhaofengli/nix-homebrew/issues/16
    # add taps from config.nix-homebrew.taps
    # taps = map (key: builtins.replaceStrings ["homebrew-"] [""] key) (builtins.attrNames config.nix-homebrew.taps);
    taps = [
      "homebrew/bundle"
      "homebrew/services"
    ];

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas
    masApps = {
      # Xcode = 497799835;
    };

    brews = [
      "kind" # podman-desktop
      "kubectl" # podman-desktop
      "podman" # podman-desktop
      "podman-compose"
    ];

    casks = [
      # mac
      "rectangle"

      # web
      "brave-browser"
      "firefox"

      # communication
      "libreoffice"
      "microsoft-auto-update" # for microsoft-teams
      "microsoft-teams"
      "slack"
      "zoom"

      # dev
      "github"
      # "docker"
      "podman-desktop"
      "visual-studio-code"
      "wezterm"

      # entertainment
      "spotify"
      "stremio"

      # work
      "cloudflare-warp"
      "intune-company-portal"
    ];
  };
}
