{ pkgs, pkgs-unstable, telescope-words, blink-cmp-words }:

let

  # Copy the config to the nix store
  nvimConfig = pkgs.stdenv.mkDerivation {
    name = "nvim-config";
    src = ./nvim;
    installPhase = ''
      cp -r . $out/
    '';
  };

  # 1. Add our config to neovim's runtimepath
  # 2. Source the init.lua file
  customRC = ''
    vim.opt.runtimepath:prepend("${nvimConfig}")
    vim.opt.runtimepath:append("${nvimConfig}/after")
    dofile("${nvimConfig}/init.lua")
  '';

  tresitterUnstableWithParsers =
    pkgs-unstable.vimPlugins.nvim-treesitter.withPlugins (p: [
      p.python
      p.markdown
      p.javascript
      p.typescript
      p.tsx
      p.lua
      p.vim
      p.vimdoc
      p.json
      p.html
      p.nix
      p.yaml
      p.bash
      p.haskell
      p.c
      p.sql
      p.latex
      p.diff
      p.xml
    ]);

  plugins = [
    tresitterUnstableWithParsers
    pkgs-unstable.vimPlugins.nvim-treesitter-textobjects
    pkgs-unstable.vimPlugins.neotest
    pkgs-unstable.vimPlugins.neotest-python
    pkgs-unstable.vimPlugins.neotest-vitest
    pkgs.vimPlugins.plenary-nvim
    pkgs.vimPlugins.catppuccin-nvim
    pkgs.vimPlugins.telescope-nvim
    pkgs.vimPlugins.telescope-live-grep-args-nvim
    pkgs.vimPlugins.telescope-fzf-native-nvim
    pkgs.vimPlugins.nvim-lspconfig
    pkgs.vimPlugins.lazydev-nvim
    pkgs.vimPlugins.cmp-dap
    pkgs.vimPlugins.blink-cmp
    pkgs.vimPlugins.blink-compat
    pkgs.vimPlugins.vim-markdown-toc
    pkgs.vimPlugins.markdown-preview-nvim
    pkgs.vimPlugins.conform-nvim
    pkgs.vimPlugins.nvim-dap
    pkgs.vimPlugins.nvim-web-devicons
    pkgs.vimPlugins.eyeliner-nvim
    pkgs.vimPlugins.vim-fugitive
    pkgs.vimPlugins.gitsigns-nvim
    pkgs.vimPlugins.lualine-nvim
    pkgs.vimPlugins.tmux-nvim
    pkgs.vimPlugins.copilot-lua
    pkgs.vimPlugins.indent-blankline-nvim
    pkgs.vimPlugins.render-markdown-nvim
    pkgs.vimPlugins.vimtex
    pkgs.vimPlugins.mini-ai
    pkgs.vimPlugins.codecompanion-nvim
    pkgs.vimPlugins.codecompanion-history-nvim
    pkgs.vimPlugins.oil-nvim
    pkgs.vimPlugins.diffview-nvim
    telescope-words.packages.${pkgs.stdenv.hostPlatform.system}.default
    blink-cmp-words.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  extraPackages = [
    # binaries
    pkgs.gcc
    # telescope
    pkgs.ripgrep
    pkgs.fd
    # copilot
    pkgs.nodejs
    # typescript
    pkgs.typescript-language-server
    pkgs.vscode-langservers-extracted # eslint language server
    # python
    pkgs.pyright
    # bash
    pkgs.bash-language-server # lsp
    pkgs.shfmt # formatter
    # markdown
    pkgs.marksman # lsp
    pkgs.mdformat # formatter
    # nix
    pkgs.nixfmt-classic
    pkgs.nixd
    # sql
    pkgs.sqls
    # html
    pkgs.emmet-language-server
    # yml
    pkgs.yaml-language-server
    # debugging
    pkgs.vscode-js-debug
    # lua
    pkgs.lua-language-server
    pkgs.stylua
  ];

  extraPython3Packages = pyPkgs: [ pyPkgs.debugpy ];

in {
  # wrapNeovimUnstable is a curried function that is partially applied by callPackage here:
  # https://github.com/NixOS/nixpkgs/blob/a8d610af3f1a5fb71e23e08434d8d61a466fc942/pkgs/top-level/all-packages.nix
  # and defined here: https://github.com/NixOS/nixpkgs/blob/a8d610af3f1a5fb71e23e08434d8d61a466fc942/pkgs/applications/editors/neovim/wrapper.nix
  # We use .override to change the python3 argument that callPackage provided (from the default
  # python3 to python312). Then we call the resulting function with neovim-unwrapped and our
  # desired wrapper configuration parameters.
  package = (pkgs.wrapNeovimUnstable.override { python3 = pkgs.python313; })
    pkgs.neovim-unwrapped {
      # These parameters go to the 'wrapper' function
      withPython3 = true;
      withNodeJs = true;
      withRuby = false;
      withPerl = false;
      extraPython3Packages = extraPython3Packages;
      plugins = plugins;
      luaRcContent = customRC;
    };
  extraPackages = extraPackages;
}

