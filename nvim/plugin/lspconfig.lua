local autocommands = require("config.autocommands")
local utils = require("utils.lsp")

local config = function()
	autocommands.lspconfig()

	vim.lsp.enable("pyright")
	vim.lsp.enable("lua_ls")
	vim.lsp.enable("marksman")
	vim.lsp.enable("bashls")
	vim.lsp.enable("nixd")
	vim.lsp.enable("ts_ls")
	vim.lsp.enable("sqlls")
	vim.lsp.enable("yamlls")
	vim.lsp.enable("emmet_language_server")

	vim.lsp.config("ts_ls", {
		commands = {
			OrganizeTSImports = {
				utils.tsserver_organize_imports,
				description = "Organize Typescipt imports for current file",
			},
		},
	})
end

config()
