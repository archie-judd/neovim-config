{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    telescope-words.url =
      "github:archie-judd/telescope-words.nvim?ref=development";
    blink-cmp-words.url = "github:archie-judd/blink-cmp-words?ref=development";
  };

  outputs = { flake-utils, nixpkgs, nixpkgs-unstable, telescope-words
    , blink-cmp-words, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlay = final: prev: {
          vimPlugins = prev.vimPlugins // {
            codecompanion-nvim = prev.vimUtils.buildVimPlugin {
              pname = "codecompanion-custom";
              version = "2025-11-12";
              src = prev.fetchFromGitHub {
                owner = "olimorris";
                repo = "codecompanion.nvim";
                rev = "47e6e1d24864d2bf8ace8904eff7a41bdf1d3126";
                sha256 = "sha256-1h8nyVJcwRO8l5nQHGE3MTZkHz68x+RF112mfYwdgZw=";
              };
              dependencies = [ prev.vimPlugins.plenary-nvim ];
              checkInputs = [
                # Optional completion
                prev.vimPlugins.blink-cmp
                prev.vimPlugins.nvim-cmp
                # Optional pickers
                prev.vimPlugins.fzf-lua
                prev.vimPlugins.mini-nvim
                prev.vimPlugins.snacks-nvim
                prev.vimPlugins.telescope-nvim
              ];
              nvimSkipModules = [
                # Requires setup call
                "codecompanion.actions.static"
                "codecompanion.actions.init"
                # Test
                "minimal"
              ];
              meta.homepage =
                "https://github.com/olimorris/codecompanion.nvim/";
              meta.hydraPlatforms = [ ];
            };
            # We need to override the history plugin to depend on our custom codecompanion (otherwise it provides the original one, causing conflicts).
            codecompanion-history-nvim =
              prev.vimPlugins.codecompanion-history-nvim.overrideAttrs (old: {
                dependencies = builtins.filter
                  (dep: dep != prev.vimPlugins.codecompanion-nvim)
                  (old.dependencies or [ ])
                  ++ [ final.vimPlugins.codecompanion-nvim ];
              });
          };
        };

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          overlays = [ overlay ];
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

      in {
        packages.default = app;

        codecompanion-rev =
          pkgs-unstable.vimPlugins.codecompanion-nvim.src.rev or "unknown";
        codecompanion-sha =
          pkgs-unstable.vimPlugins.codecompanion-nvim.src.outputHash or "unknown";

      });
}
