local mappings = require("config.mappings")

vim.opt_local.spell = true
vim.opt_local.spelllang = "en_gb"

mappings.markdown_preview()
mappings.vim_markdown_toc()

vim.treesitter.start()
