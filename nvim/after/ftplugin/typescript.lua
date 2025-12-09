vim.print("Loaded typescript ftplugin")
local mappings = require("config.mappings")

vim.opt_local.colorcolumn = "101"
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true
mappings.typescript()
vim.treesitter.start()
