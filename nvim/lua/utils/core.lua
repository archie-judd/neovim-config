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

---@param path string
---@return nil | integer
function M.get_bufnr_by_absolute_path(path)
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		local buf_name = vim.api.nvim_buf_get_name(bufnr)
		if buf_name == path then
			return bufnr
		end
	end
	return nil
end

---@param pattern string
---@return nil | integer
function M.get_bufnr_by_pattern(pattern)
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		local buf_name = vim.api.nvim_buf_get_name(bufnr)
		if string.match(buf_name, pattern) ~= nil then
			return bufnr
		end
	end
	return nil
end

---@param bufnr integer
---@return integer | nil
function M.get_winnr_for_bufnr(bufnr)
	for _, winnr in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(winnr) == bufnr then
			return winnr
		end
	end
	return nil
end

---@param winnr integer
---@return integer | nil
function M.get_tabnr_for_winnr(winnr)
	for _, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
		for _, tab_winnr in ipairs(vim.api.nvim_tabpage_list_wins(tabnr)) do
			if tab_winnr == winnr then
				return tabnr
			end
		end
	end
	return nil
end

---@param bufnr integer
---@return integer | nil
function M.get_tabnr_for_bufnr(bufnr)
	local winnr = M.get_winnr_for_bufnr(bufnr)
	if winnr ~= nil then
		local tabnr = M.get_tabnr_for_winnr(winnr)
		return tabnr
	end
	return nil
end

function M.user_input_or_nil(prompt)
	local input = vim.fn.input(prompt)
	if input == "" then
		return nil
	end
	return input
end

return M
