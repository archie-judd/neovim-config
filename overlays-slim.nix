{ nvim-treesitter-main }:

[
  nvim-treesitter-main.overlays.default
  (final: prev: {
    vimPlugins = prev.vimPlugins.extend (f: p: {
      nvim-treesitter = p.nvim-treesitter.withPlugins (p: [
        p.python
        p.markdown
        p.lua
        p.vim
        p.vimdoc
        p.json
        p.nix
        p.yaml
        p.bash
      ]);
      nvim-treesitter-textobjects =
        p.nvim-treesitter-textobjects.overrideAttrs {
          dependencies = [ f.nvim-treesitter ];
        };
      neotest =
        p.neotest.overrideAttrs { dependencies = [ f.nvim-treesitter ]; };
    });
  })
]
