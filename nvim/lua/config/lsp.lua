local autocommands = require("config.autocommands")

autocommands.lspconfig()

vim.lsp.enable("pyright")
vim.lsp.enable("lua_ls")
vim.lsp.enable("marksman")
vim.lsp.enable("bashls")
vim.lsp.enable("nixd")
vim.lsp.enable("tsgo")
vim.lsp.enable("sqlls")
vim.lsp.enable("yamlls")
vim.lsp.enable("emmet_language_server")
vim.lsp.enable("texlab")

vim.lsp.config("tsgo", {
	settings = {
		typescript = {
			format = {
				tabSize = 2,
				indentSize = 2,
				convertTabsToSpaces = true, -- Use tabs, not spaces
			},
		},
		javascript = {
			format = {
				tabSize = 2,
				indentSize = 2,
				convertTabsToSpaces = true,
			},
		},
	},
})
