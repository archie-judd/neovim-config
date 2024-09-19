local M = {}

function M.tsserver_organize_imports()
	local params = {
		command = "_typescript.organizeImports",
		arguments = { vim.api.nvim_buf_get_name(0) },
		title = "",
	}
	vim.print("Organizing imports for: " .. vim.inspect(params.arguments))
	vim.lsp.buf.execute_command(params)
end

return M
