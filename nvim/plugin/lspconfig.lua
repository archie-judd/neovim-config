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
	vim.lsp.enable("texlab")

	vim.lsp.config("ts_ls", {
		on_attach = function(client, bufnr)
			-- This happens asynchronously, so we need to ensure we don't register the autocmd multiple times.
			-- We also add a handler to write the file after organizing imports.
			local organizing = false
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = bufnr,
				callback = function()
					if organizing then
						return
					end

					organizing = true
					local range_params = vim.lsp.util.make_range_params(nil, "utf-8")
					local params = {
						textDocument = range_params.textDocument,
						range = range_params.range,
						context = {
							only = { "source.organizeImports" },
							diagnostics = {},
						},
					}
					vim.lsp.buf_request(
						bufnr,
						"textDocument/codeAction",
						params,
						-- Callback handler to write the file after organizing imports
						function(err, result, _)
							if err then
								organizing = false
								pcall(vim.cmd.write)
								return
							end
							if result then
								for _, action in ipairs(result) do
									if action.edit then
										vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
									elseif action.command then
										vim.lsp.buf_request_sync(0, "workspace/executeCommand", action.command)
									end
								end
							end
							organizing = false
							vim.schedule(function()
								pcall(vim.cmd.write)
							end)
						end
					)
					return true
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
