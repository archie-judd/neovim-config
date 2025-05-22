{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    telescope-words.url =
      "github:archie-judd/telescope-words.nvim?ref=development";
  };

  outputs = { flake-utils, nixpkgs, nixpkgs-unstable, telescope-words, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # We need a node overlay because of: https://github.com/NixOS/nixpkgs/issues/402079
        node-overlay = (final: prev: {
          nodejs = prev.nodejs_22;
          nodejs-slim = prev.nodejs-slim_22;
          nodejs_20 = prev.nodejs_22;
          nodejs-slim_20 = prev.nodejs-slim_22;
        });
        pkgs = import nixpkgs {
          system = system;
          overlays = [ node-overlay ];
        };
        pkgs-unstable = import nixpkgs-unstable {
          system = system;
          overlays = [ node-overlay ];
        };

        neovim = pkgs.callPackage ./neovim.nix {
          pkgs = pkgs;
          pkgs-unstable = pkgs-unstable;
          telescope-words = telescope-words;
        };

        app = pkgs.writeShellApplication {
          name = "nvim";
          text = ''${neovim.package}/bin/nvim "$@"'';
          runtimeInputs = neovim.extraPackages;
        };

      in { packages.default = app; });
}

