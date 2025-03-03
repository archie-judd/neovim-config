local M = {}

vim.g.floating_term_win = nil
vim.g.term_buffer = nil

function M.open()
	local WINDOW_HEIGHT = 0.85
	local WINDOW_WIDTH = 0.3
	local TOP_MARGIN = 0.075
	local RIGHT_MARGIN = 0.025

	if
		vim.g.floating_term_win
		and vim.api.nvim_win_is_valid(vim.g.floating_term_win)
		and vim.g.term_buffer
		and vim.api.nvim_buf_is_valid(vim.g.term_buffer)
	then
		vim.api.nvim_set_current_win(vim.g.floating_term_win)
		vim.cmd("startinsert")
	else
		local opts = {
			relative = "editor",
			width = math.floor(vim.o.columns * WINDOW_WIDTH),
			height = math.floor((vim.o.lines - 2) * WINDOW_HEIGHT),
			row = math.floor((vim.o.lines - 2) * TOP_MARGIN),
			col = math.floor((vim.o.columns * (1 - RIGHT_MARGIN - WINDOW_WIDTH))),
			style = "minimal",
			border = "rounded",
		}
		if vim.g.term_buffer and vim.api.nvim_buf_is_valid(vim.g.term_buffer) then
			vim.g.floating_term_win = vim.api.nvim_open_win(vim.g.term_buffer, true, opts)
			vim.cmd("startinsert")
		else
			vim.g.term_buffer = vim.api.nvim_create_buf(false, true)
			vim.g.floating_term_win = vim.api.nvim_open_win(vim.g.term_buffer, true, opts)
			vim.cmd("terminal")
			vim.cmd("startinsert")
		end
	end
end

function M.close()
	if vim.g.floating_term_win and vim.api.nvim_win_is_valid(vim.g.floating_term_win) then
		vim.api.nvim_win_close(vim.g.floating_term_win, true)
		vim.g.floating_term_win = nil
	end
end

return M
