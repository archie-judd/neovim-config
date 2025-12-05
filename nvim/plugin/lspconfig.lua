local autocommands = require("config.autocommands")

local function is_client_ready(client_name)
	local buf_clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
	for _, client in ipairs(buf_clients) do
		if client.name == client_name and client.initialized then
			return true
		end
	end
	return false
end

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
	vim.lsp.enable("texlab")

	vim.lsp.config("ts_ls", {
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
					if is_client_ready(client.name) then
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
