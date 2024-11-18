local M = {}

-- Variables to store the layout and maximised state
local restore_cmd = nil
local max_win_width = nil
local max_win_height = nil

function M.is_maximised()
	local win_height = vim.api.nvim_win_get_height(0)
	local win_width = vim.api.nvim_win_get_width(0)
	if win_height == max_win_height and win_width == max_win_width then
		return true
	else
		return false
	end
end

function M.maximise()
	restore_cmd = vim.fn.winrestcmd()
	vim.cmd("vert resize | resize")
	max_win_height = vim.api.nvim_win_get_height(0)
	max_win_width = vim.api.nvim_win_get_width(0)
end

function M.restore()
	if restore_cmd then
		vim.cmd(restore_cmd)
	end
	restore_cmd = nil
	max_win_height = nil
	max_win_width = nil
end

function M.toggle_maximise()
	if M.is_maximised() then
		M.restore()
	else
		M.maximise()
	end
end

vim.api.nvim_create_autocmd({ "WinLeave" }, {
	callback = function()
		M.restore()
	end,
})

return M
