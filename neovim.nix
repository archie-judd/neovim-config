{ pkgs, pkgs-stable }:

let

  # Copy the config to the nix store
  nvimConfig = pkgs.stdenv.mkDerivation {
    name = "nvim-config";
    src = ./nvim;
    installPhase = ''
      cp -r . $out/
    '';
  };

  # This is written as vimscript, so we use an embedded lua block.
  # 1. Add our config to neovim's runtimepath
  # 2. Source the init.lua file
  customRC = ''
    lua <<EOF
    vim.opt.runtimepath:prepend("${nvimConfig}")
    dofile("${nvimConfig}/init.lua")
    EOF
  '';

  plugins = [
    pkgs.vimPlugins.nvim-treesitter
    pkgs.vimPlugins.nvim-treesitter-parsers.python
    pkgs.vimPlugins.nvim-treesitter-parsers.markdown
    pkgs.vimPlugins.nvim-treesitter-parsers.javascript
    pkgs.vimPlugins.nvim-treesitter-parsers.typescript
    pkgs.vimPlugins.nvim-treesitter-parsers.lua
    pkgs.vimPlugins.nvim-treesitter-parsers.vim
    pkgs.vimPlugins.nvim-treesitter-parsers.vimdoc
    pkgs.vimPlugins.nvim-treesitter-parsers.json
    pkgs.vimPlugins.nvim-treesitter-parsers.html
    pkgs.vimPlugins.nvim-treesitter-parsers.nix
    pkgs.vimPlugins.nvim-treesitter-parsers.yaml
    pkgs.vimPlugins.nvim-treesitter-parsers.bash
    pkgs.vimPlugins.nvim-treesitter-parsers.haskell
    pkgs.vimPlugins.nvim-treesitter-parsers.c
    pkgs-stable.vimPlugins.nvim-treesitter-parsers.sql
    pkgs.vimPlugins.nvim-treesitter-textobjects
    pkgs.vimPlugins.oil-nvim
    pkgs.vimPlugins.catppuccin-nvim
    pkgs.vimPlugins.telescope-nvim
    pkgs.vimPlugins.telescope-live-grep-args-nvim
    pkgs.vimPlugins.nvim-lspconfig
    pkgs.vimPlugins.neodev-nvim
    pkgs.vimPlugins.nvim-cmp
    pkgs.vimPlugins.cmp-nvim-lsp
    pkgs.vimPlugins.cmp-path
    pkgs.vimPlugins.cmp-dap
    pkgs.vimPlugins.cmp-cmdline
    pkgs.vimPlugins.lsp_signature-nvim
    pkgs.vimPlugins.vim-markdown-toc
    pkgs.vimPlugins.markdown-preview-nvim
    pkgs.vimPlugins.conform-nvim
    pkgs.vimPlugins.nvim-dap
    pkgs.vimPlugins.diffview-nvim
    pkgs.vimPlugins.nvim-web-devicons
    pkgs-stable.vimPlugins.eyeliner-nvim # nvim_buf_del_keymap issue on unstable 2024-08-27
    pkgs.vimPlugins.vim-fugitive
    pkgs.vimPlugins.gitsigns-nvim
    pkgs.vimPlugins.lualine-nvim
    pkgs.vimPlugins.mini-nvim
    pkgs-stable.vimPlugins.neotest # neotest-5.4.0-unstable failed to build
    pkgs.vimPlugins.neotest-python
    pkgs.vimPlugins.tmux-nvim
    pkgs.vimPlugins.copilot-lua
    pkgs.vimPlugins.copilot-cmp
  ];

  extraPackages = [
    pkgs.gcc
    pkgs.ripgrep
    pkgs.fd
    pkgs.bash-language-server
    pkgs.nodePackages.typescript-language-server
    pkgs.haskell-language-server
    pkgs.lua-language-server
    pkgs.marksman
    pkgs.ruff
    pkgs.pyright
    pkgs.nixd
    pkgs-stable.nodePackages.vscode-langservers-extracted # vscode-langservers-extracted-4.10.0 failed on unstable 2024-08-20
    pkgs.nodePackages.eslint
    pkgs.prettierd
    pkgs.shfmt
    pkgs.stylua
    pkgs.sqls
    pkgs.nixfmt-classic
    pkgs.black
    pkgs.isort
    pkgs.ormolu
    pkgs.vscode-js-debug
    pkgs.nodejs
    (pkgs.python3.withPackages (pyPkgs: [ pyPkgs.debugpy ]))
  ];

in {
  package = pkgs.neovim.override {
    configure = {
      packages.all.start = plugins;
      customRC = customRC;
    };
  };

  extraPackages = extraPackages;
}
