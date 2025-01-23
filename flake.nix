{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.follows = "nix/nixpkgs";

    nix = {
      url = "github:NixOS/nix/latest-release";
      # inputs.nixpkgs.follows = "nixpkgs";
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
      inputs = {
        nix.follows = "nix";
        nixpkgs.follows = "nixpkgs";
      };
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "nix/flake-compat";
      };
    };

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix-darwin.follows = "nix-darwin";
      };
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks-nix.follows = "nix/git-hooks-nix";
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
    git-hooks-nix,
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

    pkgs = nixpkgs.legacyPackages.${system};
    treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
    git-hooks-checks = git-hooks-nix.lib.${system}.run (import ./git-hooks.nix {});

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
      inherit git-hooks-checks;
      formatting = treefmtEval.config.build.check self;
    };
  };
}
