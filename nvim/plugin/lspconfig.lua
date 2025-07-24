local autocommands = require("config.autocommands")

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
	vim.lsp.enable("eslint")
	vim.lsp.enable("emmet_language_server")

	vim.lsp.config("ts_ls", {
		on_attach = function(client, bufnr)
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.code_action({
						context = {
							only = { "source.organizeImports" },
							diagnostics = {},
						},
						apply = true,
					})
				end,
			})
		end,
	})

	local base_on_attach = vim.lsp.config.eslint.on_attach
	vim.lsp.config("eslint", {
		on_attach = function(client, bufnr)
			if not base_on_attach then
				return
			end

			base_on_attach(client, bufnr)
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = bufnr,
				command = "LspEslintFixAll",
			})
		end,
	})
end

config()
