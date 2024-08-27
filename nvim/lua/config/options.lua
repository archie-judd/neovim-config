vim.wo.number = true
vim.wo.relativenumber = true
vim.o.splitright = true
vim.o.pumheight = 10
vim.o.completeopt = "menuone,noinsert,preview"
vim.o.shortmess = "ctF" -- 'c' means 'don't show ins-completion mode messages', 't' means truncate file message when opening a file, 'F' means don't show file edit messages upon opening
vim.o.laststatus = 3 -- only one statusline
vim.cmd.colorscheme("catppuccin-mocha")
vim.api.nvim_set_hl(0, "NormalFloat", { fg = "none", bg = "none" }) -- fix oil background
