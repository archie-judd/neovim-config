local M = {}

---@param keep number The buffer number to keep open, counted from left, from 1 (1 is leftmost).
function M.close(keep)
	local diff_windows = {}
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.wo[win].diff then
			local col = vim.api.nvim_win_get_position(win)[2]
			table.insert(diff_windows, { win = win, buf = vim.api.nvim_win_get_buf(win), col = col })
		end
	end

	table.sort(diff_windows, function(a, b)
		return a.col < b.col
	end)

	for i, win in ipairs(diff_windows) do
		if i ~= keep then
			vim.api.nvim_buf_delete(win.buf, { force = true })
		else
			vim.api.nvim_win_set_option(win.win, "diff", false)
		end
	end
end

function M.go_to_first_conflict()
	vim.cmd("normal! gg")
	vim.cmd("normal! ]c")
	vim.cmd("normal! [c")
end

function M.go_to_last_conflict()
	vim.cmd("normal! G")
	vim.cmd("normal! [c")
	vim.cmd("normal! ]c")
end

return M
