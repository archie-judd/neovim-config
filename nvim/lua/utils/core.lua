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

---@param force boolean
function M.close_active_or_topmost_floating_window(force)
	-- If in a floating window, close it
	local current_win = vim.api.nvim_get_current_win()
	local current_config = vim.api.nvim_win_get_config(current_win)
	if current_config.zindex then
		vim.api.nvim_win_close(current_win, force)
	-- Otherwise take the topmost floating window and close that
	else
		local windows_with_zindex = {}
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local config = vim.api.nvim_win_get_config(win)
			if config.zindex ~= nil then
				table.insert(windows_with_zindex, { win = win, zindex = config.zindex })
			end
		end

		table.sort(windows_with_zindex, function(a, b)
			return a.zindex < b.zindex
		end)
		if #windows_with_zindex > 0 then
			local first = windows_with_zindex[1]
			vim.api.nvim_win_close(first.win, force)
		end
	end
end

---@return string
function M.get_char_under_cursor()
	local position = vim.api.nvim_win_get_cursor(0)
	return string.sub(vim.api.nvim_get_current_line(), position[2], position[2])
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

function M.move_to_previous_window()
	local current_win = vim.api.nvim_get_current_win()
	local previous_win = vim.fn.win_getid(vim.fn.winnr("#"))
	if previous_win and vim.api.nvim_win_is_valid(previous_win) and current_win ~= previous_win then
		vim.api.nvim_set_current_win(previous_win)
	end
end

return M
