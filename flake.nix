{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    telescope-words.url =
      "github:archie-judd/telescope-words.nvim?ref=development";
    blink-cmp-words.url = "github:archie-judd/blink-cmp-words?ref=development";
    nvim-treesitter-main.url = "github:iofq/nvim-treesitter-main";
  };

  outputs = { flake-utils, nixpkgs, nixpkgs-unstable, telescope-words
    , blink-cmp-words, nvim-treesitter-main, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = import ./overlays.nix {
          nvim-treesitter-main = nvim-treesitter-main;
        };
        pkgs = import nixpkgs {
          system = system;
          overlays = overlays;
        };
        pkgs-unstable = import nixpkgs-unstable {
          system = system;
          overlays = overlays;
        };

        neovim = pkgs.callPackage ./neovim.nix {
          pkgs = pkgs;
          pkgs-unstable = pkgs-unstable;
          telescope-words = telescope-words;
          blink-cmp-words = blink-cmp-words;
        };

        app = pkgs.writeShellApplication {
          name = "nvim";
          text = ''${neovim.package}/bin/nvim "$@"'';
          runtimeInputs = neovim.extraPackages;
        };

      in { packages.default = app; });
}
