local M = {}

---@param opts table
function M.switch_windows(opts)
	opts = opts or {}
	local windows = vim.api.nvim_tabpage_list_wins(0)
	local current_window = vim.api.nvim_get_current_win()
	local current_index = 0
	for i, win in ipairs(windows) do
		if win == current_window then
			current_index = i
			break
		end
	end
	local next_index
	if opts.reverse then
		next_index = (current_index - 2) % #windows + 1
	else
		next_index = (current_index % #windows) + 1
	end
	if vim.api.nvim_win_is_valid(windows[next_index]) then
		vim.api.nvim_set_current_win(windows[next_index])
	end
end

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
			return a.zindex > b.zindex
		end)
		if #windows_with_zindex > 0 then
			local first = windows_with_zindex[1]
			vim.api.nvim_win_close(first.win, force)
		end
	end
end

function M.next_conflict()
	vim.fn.search("^<<<<<<< ", "w")
end

function M.prev_conflict()
	vim.fn.search("^<<<<<<< ", "wb")
end

return M
