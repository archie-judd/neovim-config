local M = {}

vim.g.term_win = nil
vim.g.term_buffer = nil

function M.open()
	local TERMINAL_WIDTH = 0.4
	local width = math.floor(vim.o.columns * TERMINAL_WIDTH)

	if not vim.g.term_win or not vim.api.nvim_win_is_valid(vim.g.term_win) then
		vim.cmd("vsplit")
		vim.cmd("vertical resize " .. width)
		vim.g.term_win = vim.api.nvim_get_current_win()
		if not vim.g.term_buffer or not vim.api.nvim_buf_is_valid(vim.g.term_buffer) then
			vim.g.term_buffer = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_win_set_buf(vim.g.term_win, vim.g.term_buffer)
			vim.cmd("terminal")
		else
			vim.api.nvim_win_set_buf(vim.g.term_win, vim.g.term_buffer)
		end
	end
end

function M.close()
	if vim.g.term_win and vim.api.nvim_win_is_valid(vim.g.term_win) then
		vim.api.nvim_win_close(vim.g.term_win, true)
		vim.g.term_win = nil
	end
end

return M
