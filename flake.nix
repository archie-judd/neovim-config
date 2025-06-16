{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    telescope-words.url =
      "github:archie-judd/telescope-words.nvim?ref=development";
  };

  outputs = { flake-utils, nixpkgs, nixpkgs-unstable, telescope-words, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Get V17.0.0 of codecompanion.nvim
        overlay = final: prev: {
          vimPlugins = prev.vimPlugins // {
            codecompanion-nvim = prev.vimUtils.buildVimPlugin {
              pname = "codecompanion.nvim";
              version = "2025-16-15";
              src = prev.fetchFromGitHub {
                owner = "olimorris";
                repo = "codecompanion.nvim";
                rev = "621c734737801d9556cf0b50c27ef502a94b9cca";
                sha256 = "13g8lj4f9z4wrcwcnddc5rmgly13269qi2jpx9a8bm93p8pgz12g";
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
        };

        app = pkgs.writeShellApplication {
          name = "nvim";
          text = ''${neovim.package}/bin/nvim "$@"'';
          runtimeInputs = neovim.extraPackages;
        };

      in { packages.default = app; });
}
