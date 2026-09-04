local mappings = require("config.mappings")
local usercommands = require("config.usercommands")

vim.opt_local.spell = true
vim.opt_local.spelllang = "en_gb"

mappings.markdown_tasks()
usercommands.markdown_log()

vim.treesitter.start()
