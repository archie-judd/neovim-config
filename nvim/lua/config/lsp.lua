local autocommands = require("config.autocommands")

autocommands.lspconfig()

local function enable_if_available(name, bin)
	if vim.fn.executable(bin) == 1 then
		vim.lsp.enable(name)
	end
end

enable_if_available("pyright", "pyright-langserver")
enable_if_available("lua_ls", "lua-language-server")
enable_if_available("marksman", "marksman")
enable_if_available("bashls", "bash-language-server")
enable_if_available("nixd", "nixd")
enable_if_available("tsgo", "tsgo")
enable_if_available("sqlls", "sql-language-server")
enable_if_available("yamlls", "yaml-language-server")
enable_if_available("emmet_language_server", "emmet-language-server")
enable_if_available("texlab", "texlab")

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
