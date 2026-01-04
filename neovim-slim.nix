{ pkgs }:

let

  # Copy the config to the nix store
  nvimConfig = pkgs.stdenv.mkDerivation {
    name = "nvim-config-slim";
    src = ./nvim;
    installPhase = ''
      cp -r . $out/
    '';
  };

  customRC = ''
    vim.opt.runtimepath:prepend("${nvimConfig}")
    vim.opt.runtimepath:append("${nvimConfig}/after")
    dofile("${nvimConfig}/init.lua")
  '';

  plugins = [
    pkgs.vimPlugins.nvim-treesitter
    pkgs.vimPlugins.nvim-treesitter-textobjects
    pkgs.vimPlugins.plenary-nvim
    pkgs.vimPlugins.catppuccin-nvim
    pkgs.vimPlugins.telescope-nvim
    pkgs.vimPlugins.telescope-live-grep-args-nvim
    pkgs.vimPlugins.telescope-fzf-native-nvim
    pkgs.vimPlugins.nvim-lspconfig
    pkgs.vimPlugins.lazydev-nvim
    pkgs.vimPlugins.blink-cmp
    pkgs.vimPlugins.conform-nvim
    pkgs.vimPlugins.nvim-web-devicons
    pkgs.vimPlugins.vim-fugitive
    pkgs.vimPlugins.gitsigns-nvim
    pkgs.vimPlugins.lualine-nvim
    pkgs.vimPlugins.mini-ai
    pkgs.vimPlugins.oil-nvim
  ];

  extraPackages = [
    # telescope
    pkgs.ripgrep
    pkgs.fd
    # bash
    pkgs.bash-language-server
    pkgs.shfmt
    # markdown
    pkgs.marksman
    # nix
    pkgs.nixfmt-classic
    pkgs.nixd
    # lua
    pkgs.lua-language-server
    pkgs.stylua
  ];

in {
  package = (pkgs.wrapNeovimUnstable.override) pkgs.neovim-unwrapped {
    withPython3 = false;
    withNodeJs = false;
    withRuby = false;
    withPerl = false;
    plugins = plugins;
    luaRcContent = customRC;
  };
  extraPackages = extraPackages;
}
