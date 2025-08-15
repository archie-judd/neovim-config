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
		on_attach = function(client, bufnr)
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = bufnr,
				callback = function()
					if not is_client_ready(client.name) then
						return
					end
					local line_count = vim.api.nvim_buf_line_count(bufnr)
					local params = {
						textDocument = {
							uri = vim.uri_from_bufnr(bufnr),
						},
						range = {
							start = { line = 0, character = 0 },
							["end"] = { line = line_count, character = 0 },
						},
						context = {
							only = { "source.organizeImports" },
							diagnostics = {},
						},
					}

					local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 3000)

					local actions_applied = 0
					if result then
						for client_id, response in pairs(result) do
							if response.result and #response.result > 0 then
								for _, action in ipairs(response.result) do
									if action.edit then
										vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
										actions_applied = actions_applied + 1
									elseif action.command then
										local res = vim.lsp.buf_request_sync(
											bufnr,
											"workspace/executeCommand",
											action.command,
											1000
										)
										if res and res[client_id] and res[client_id].result then
											actions_applied = actions_applied + 1
										elseif not res or not res[client_id] or res[client_id].error then
											vim.notify(
												"Failed to execute command: "
													.. (
														res and res[client_id] and res[client_id].error.message
														or "Unknown error"
													),
												vim.log.levels.ERROR
											)
										end
									end
								end
							elseif response.error then
								vim.notify(
									"Import organization failed: " .. response.error.message,
									vim.log.levels.ERROR
								)
							end
						end
					end
				end,
			})
		end,
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
