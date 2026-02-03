local config = function()
	local autocommands = require("config.autocommands")
	local lspconfig_utils = require("lib.plugin.lspconfig")
	vim.lsp.set_log_level("warn")

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
	vim.lsp.enable("texlab")

	vim.lsp.config("ts_ls", {
		cmd_env = {
			NODE_OPTIONS = "--max-old-space-size=16384",
		},
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

	vim.lsp.config("eslint", {
		on_attach = function(client, bufnr)
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = bufnr,
				callback = function()
					if lspconfig_utils.is_client_ready(client.name) then
						vim.lsp.buf.code_action({
							filter = function(action)
								return action.kind and action.kind:match("^source%.fixAll%.eslint")
							end,
							apply = true,
						})
					end
				end,
			})
		end,
	})
end

config()
