{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.follows = "nix/nixpkgs";

    nix = {
      url = "github:NixOS/nix/latest-release";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "nix/flake-compat";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      host.name = "yx-tay-pkf2k";
      user.name = "yuxuantay";
      specialArgs = { inherit host user; };
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs specialArgs; } {
      imports = [ ./modules/flake-parts ];
    };
}
