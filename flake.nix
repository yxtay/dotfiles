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

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    determinate,
    nix-darwin,
    home-manager,
    mac-app-util,
    nix-homebrew,
    treefmt-nix,
    ...
  }: let
    system = "aarch64-darwin"; # aarch64-darwin or x86_64-darwin
    pkgs = nixpkgs.legacyPackages.${system};

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

    treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

    specialArgs =
      inputs
      // {
        inherit host user;
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
        inherit pkgs;

        extraSpecialArgs = specialArgs;

        modules = [
          ./home
          mac-app-util.homeManagerModules.default
        ];
      };
    };

    # nix code formatter
    # formatter.${system} = pkgs.alejandra;
    formatter.${system} = treefmtEval.config.build.wrapper;

    checks.${system} = {
      formatting = treefmtEval.config.build.check self;
    };
  };
}
