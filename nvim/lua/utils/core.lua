local M = {}

---@param pattern string
---@param opts table
function M.close_buffer_by_filetype_pattern(pattern, opts)
	for i, win in ipairs(vim.fn.getwininfo()) do
		if vim.api.nvim_buf_is_loaded(win.bufnr) then
			local filetype = vim.api.nvim_get_option_value("filetype", { buf = win.bufnr })
			if string.find(filetype, pattern) then
				vim.api.nvim_buf_delete(win.bufnr, opts)
			end
		end
	end
end

---@param inactive_only boolean
---@param force boolean
function M.close_floating_windows(inactive_only, force)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_config(win).zindex and (not inactive_only or vim.api.nvim_get_current_win() ~= win) then
			vim.api.nvim_win_close(win, force)
		end
	end
end

---@return string
function M.get_char_under_cursor()
	local position = vim.api.nvim_win_get_cursor(0)
	return string.sub(vim.api.nvim_get_current_line(), position[2], position[2])
end

return M
