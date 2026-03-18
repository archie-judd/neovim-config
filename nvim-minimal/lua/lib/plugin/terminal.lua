local M = {}

M.state = {
	term_win = nil,
	term_buffer = nil,
}

function M.open()
	local TERMINAL_WIDTH = 0.4
	local width = math.floor(vim.o.columns * TERMINAL_WIDTH)

	if not M.state.term_win or not vim.api.nvim_win_is_valid(M.state.term_win) then
		vim.cmd("vsplit")
		vim.cmd("vertical resize " .. width)
		M.state.term_win = vim.api.nvim_get_current_win()
		if not M.state.term_buffer or not vim.api.nvim_buf_is_valid(M.state.term_buffer) then
			M.state.term_buffer = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_win_set_buf(M.state.term_win, M.state.term_buffer)
			vim.cmd("terminal")
		else
			vim.api.nvim_win_set_buf(M.state.term_win, M.state.term_buffer)
		end
	end
end

function M.close()
	if M.state.term_win and vim.api.nvim_win_is_valid(M.state.term_win) then
		vim.api.nvim_win_close(M.state.term_win, true)
		M.state.term_win = nil
	end
end

return M
