{ pkgs, pkgs-unstable, telescope-words }:

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
    pkgs.vimPlugins.nvim-treesitter-parsers.sql
    pkgs.vimPlugins.nvim-treesitter-textobjects
    pkgs.vimPlugins.nvim-treesitter-parsers.diff
    pkgs.vimPlugins.plenary-nvim
    pkgs.vimPlugins.catppuccin-nvim
    pkgs.vimPlugins.telescope-nvim
    pkgs.vimPlugins.telescope-live-grep-args-nvim
    pkgs.vimPlugins.nvim-lspconfig
    pkgs.vimPlugins.lazydev-nvim
    pkgs.vimPlugins.cmp-dap
    pkgs.vimPlugins.blink-cmp
    pkgs.vimPlugins.blink-compat
    pkgs.vimPlugins.lsp_signature-nvim
    pkgs.vimPlugins.vim-markdown-toc
    pkgs.vimPlugins.markdown-preview-nvim
    pkgs.vimPlugins.conform-nvim
    pkgs.vimPlugins.nvim-dap
    pkgs.vimPlugins.nvim-web-devicons
    pkgs.vimPlugins.eyeliner-nvim
    pkgs.vimPlugins.vim-fugitive
    pkgs.vimPlugins.gitsigns-nvim
    pkgs.vimPlugins.lualine-nvim
    pkgs.vimPlugins.neotest
    pkgs.vimPlugins.neotest-python
    pkgs.vimPlugins.tmux-nvim
    pkgs.vimPlugins.copilot-lua
    pkgs.vimPlugins.indent-blankline-nvim
    pkgs.vimPlugins.render-markdown-nvim
    pkgs.vimPlugins.mini-surround
    pkgs.vimPlugins.mini-ai
    pkgs-unstable.vimPlugins.codecompanion-nvim # Not available in stable
    pkgs-unstable.vimPlugins.oil-nvim # Floating preview was not in stable
    pkgs-unstable.vimPlugins.diffview-nvim
    telescope-words.packages.${pkgs.system}.default
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
    pkgs-unstable.vscode-js-debug
    # lua
    pkgs.lua-language-server
    pkgs.stylua
  ];

  extraPython3Packages = pyPkgs: [ pyPkgs.debugpy ];

in {

  package = pkgs-unstable.neovim.override {
    configure = {
      packages.all.start = plugins;
      customRC = customRC;
    };
    withPython3 = true;
    withNodeJs = true;
    withRuby = false;
    extraPython3Packages = extraPython3Packages;
  };

  extraPackages = extraPackages;
}

