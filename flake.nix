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
              pname = "codecompanion.nvim";
              version = "2025-11-11";
              src = prev.fetchFromGitHub {
                owner = "archie-judd";
                repo = "codecompanion.nvim";
                rev = "fix-load-user-slash-commands";
                sha256 = "sha256-0WrwPTe44qsljco5tK7VyQ9SSFBYFpNzZYfa08X5yCY";
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
                "https://github.com/archie-judd/codecompanion.nvim/";
              meta.hydraPlatforms = [ ];
            };
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

      in { packages.default = app; });
}
