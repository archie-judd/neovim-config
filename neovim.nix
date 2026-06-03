{
  pkgs,
  pkgs-unstable,
  telescope-words,
  blink-cmp-words,
}:

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

  tresitterUnstableWithParsers = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
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
    pkgs.vimPlugins.nvim-treesitter-textobjects
    pkgs.vimPlugins.nvim-lspconfig
    pkgs.vimPlugins.neotest
    pkgs.vimPlugins.neotest-python
    pkgs.vimPlugins.neotest-vitest
    pkgs.vimPlugins.codecompanion-nvim
    pkgs.vimPlugins.codecompanion-history-nvim
    pkgs.vimPlugins.plenary-nvim
    pkgs.vimPlugins.catppuccin-nvim
    pkgs.vimPlugins.telescope-nvim
    pkgs.vimPlugins.telescope-live-grep-args-nvim
    pkgs.vimPlugins.telescope-fzf-native-nvim
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
    pkgs.vimPlugins.blink-indent
    pkgs.vimPlugins.render-markdown-nvim
    pkgs.vimPlugins.vimtex
    pkgs.vimPlugins.mini-ai
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
    # bash
    pkgs.bash-language-server # lsp
    pkgs.shfmt # formatter
    # markdown
    pkgs.marksman # lsp
    pkgs.mdformat # formatter
    # nix
    pkgs.nixd # lsp
    pkgs.nixfmt # formatter
    # lua
    pkgs.lua-language-server # lsp
    pkgs.stylua # formatter
    # js/ts
    pkgs.vscode-langservers-extracted # eslint lsp
  ];

in
{
  # wrapNeovimUnstable is a curried function that is partially applied by callPackage here:
  # https://github.com/NixOS/nixpkgs/blob/a8d610af3f1a5fb71e23e08434d8d61a466fc942/pkgs/top-level/all-packages.nix
  # and defined here: https://github.com/NixOS/nixpkgs/blob/a8d610af3f1a5fb71e23e08434d8d61a466fc942/pkgs/applications/editors/neovim/wrapper.nix
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
