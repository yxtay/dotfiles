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

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.follows = "nix/flake-parts";
    systems.follows = "mac-app-util/systems";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks-nix.follows = "nix/git-hooks-nix";
  };

  outputs =
    inputs:
    let
      system = "aarch64-darwin"; # aarch64-darwin or x86_64-darwin
      pkgs = import inputs.nixpkgs { inherit system; };
      inherit (pkgs.stdenv) isDarwin;

      host = {
        name = "yx-tay-pkf2k";
      };

      user = {
        name = "yuxuantay";
        home = (if isDarwin then "/Users/" else "/home/") + user.name;
        githubName = "yxtay";
        email = "5795122+${user.githubName}@users.noreply.github.com";
        workEmail = "139188417+daip-yxtay@users.noreply.github.com";
      };

      specialArgs = inputs // {
        inherit system host user;
      };
    in
    inputs.flake-parts.lib.mkFlake
      {
        inherit inputs;
        inherit specialArgs;
      }
      (
        inputs@{ systems, ... }:
        {
          flake = {
            # Nix Darwin configuration entrypoint
            # Available through 'nix run nix-darwin -- switch --flake .#simple'
            darwinConfigurations = import ./configurations/darwin inputs;

            # Standalone home-manager configuration entrypoint
            # Available through 'nix run home-manager -- switch --flake .#simple'
            homeConfigurations = import ./configurations/home inputs;
          };

          imports = [
            ./modules/flake-parts/treefmt.nix
            ./modules/flake-parts/git-hooks.nix
          ];
          systems = import systems;
        }
      );
}
