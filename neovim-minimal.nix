{ pkgs, pkgs-unstable }:

let

  nvimConfig = pkgs.stdenv.mkDerivation {
    name = "nvim-minimal-config";
    src = ./nvim-minimal;
    installPhase = ''
      cp -r . $out/
    '';
  };

  customRC = ''
    vim.opt.runtimepath:prepend("${nvimConfig}")
    vim.opt.runtimepath:append("${nvimConfig}/after")
    dofile("${nvimConfig}/init.lua")
  '';

  tresitterUnstableWithParsers =
    pkgs-unstable.vimPlugins.nvim-treesitter.withPlugins (p: [
      p.javascript
      p.typescript
      p.tsx
      p.html
      p.css
      p.json
      p.c
      p.python
      p.haskell
      p.nix
      p.bash
      p.lua
      p.vim
      p.vimdoc
      p.yaml
      p.sql
      p.xml
      p.markdown
      p.latex
      p.diff
    ]);

  plugins = [
    tresitterUnstableWithParsers
    pkgs.vimPlugins.plenary-nvim
    pkgs.vimPlugins.catppuccin-nvim
    pkgs.vimPlugins.telescope-nvim
    pkgs.vimPlugins.telescope-live-grep-args-nvim
    pkgs.vimPlugins.telescope-fzf-native-nvim
    pkgs.vimPlugins.nvim-web-devicons
    pkgs.vimPlugins.tmux-nvim
    pkgs.vimPlugins.oil-nvim
  ];

  extraPackages = [
    pkgs.gcc
    pkgs.ripgrep
    pkgs.fd
  ];

in {
  package = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
    withPython3 = false;
    withNodeJs = false;
    withRuby = false;
    withPerl = false;
    plugins = plugins;
    luaRcContent = customRC;
  };
  extraPackages = extraPackages;
}
