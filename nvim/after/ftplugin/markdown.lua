local mappings = require("config.mappings")

vim.opt_local.spell = true
vim.opt_local.spelllang = "en_gb"

mappings.markdown_tasks()
mappings.markdown_notes()

vim.treesitter.start()
