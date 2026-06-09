local M = {}

---@param client_name string
---@return boolean
function M.is_client_ready(client_name)
	local buf_clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
	for _, client in ipairs(buf_clients) do
		if client.name == client_name and client.initialized then
			return true
		end
	end
	return false
end

return M
