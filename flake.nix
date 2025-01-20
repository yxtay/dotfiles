{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    flake-compat.url = "github:edolstra/flake-compat";
    systems.url = "github:nix-systems/default-darwin";

    nix = {
      url = "github:NixOS/nix/latest-release";
      # inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.flake-compat.follows = "flake-compat";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix.follows = "nix";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-utils.follows = "flake-utils";
      inputs.systems.follows = "systems";
    };

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-darwin.follows = "nix-darwin";
    };

    flox = {
      url = "github:flox/flox";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit-hooks.follows = "pre-commit-hooks";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    determinate,
    nix-darwin,
    home-manager,
    mac-app-util,
    nix-homebrew,
    ...
  }: let
    system = "aarch64-darwin"; # aarch64-darwin or x86_64-darwin

    host = {
      name = "yx-tay-pkf2k";
    };

    user = {
      name = "yuxuantay";
      home = "/Users/${user.name}";
      githubName = "yxtay";
      email = "5795122+${user.githubName}@users.noreply.github.com";
      workEmail = "139188417+daip-yxtay@users.noreply.github.com";
    };

    flox = inputs.flox.packages.${system}.default;

    specialArgs =
      inputs
      // {
        inherit flox host user;
      };
  in {
    # Nix Darwin configuration entrypoint
    # Available through 'nix run nix-darwin -- switch --flake .#simple'
    darwinConfigurations = {
      "${host.name}" = nix-darwin.lib.darwinSystem {
        inherit system specialArgs;

        modules = [
          ./darwin

          determinate.darwinModules.default
          mac-app-util.darwinModules.default
          nix-homebrew.darwinModules.nix-homebrew

          # home manager
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              backupFileExtension = "backup";
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgs;
              sharedModules = [
                mac-app-util.homeManagerModules.default
              ];
              users.${user.name} = import ./home;
            };
          }
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'nix run home-manager -- switch --flake .#simple'
    homeConfigurations = {
      "${user.name}" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = specialArgs;
        pkgs = nixpkgs.legacyPackages.${system}; # Home-manager requires 'pkgs' instance

        modules = [
          ./home
          mac-app-util.homeManagerModules.default
        ];
      };
    };

    # nix code formatter
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
