local M = {}

-- Variables to store the layout and maximised state
local original_row = nil
local original_col = nil
local original_height = nil
local original_width = nil
local maximised_row = nil
local maximised_col = nil
local maximised_height = nil
local maximised_width = nil

function M.is_maximised()
	local win_height = vim.api.nvim_win_get_height(0)
	local win_width = vim.api.nvim_win_get_width(0)
	if win_height == maximised_height and win_width == maximised_width then
		return true
	else
		return false
	end
end

function M.maximise()
	local MAX_HEIGHT = 0.975
	local MAX_WIDTH = 0.975
	local cols = vim.o.columns
	local rows = vim.o.lines - 2

	-- get the current configuration of the floating window
	local win_config = vim.api.nvim_win_get_config(0)
	original_row = win_config.row
	original_col = win_config.col
	original_height = win_config.height
	original_width = win_config.width

	-- update the row and col to reposition the window
	maximised_row = math.floor(rows * (1 - MAX_HEIGHT) / 2)
	maximised_col = math.floor(cols * (1 - MAX_WIDTH) / 2)
	maximised_height = math.floor(rows * MAX_HEIGHT)
	maximised_width = math.floor(cols * MAX_WIDTH)
	win_config.row = maximised_row
	win_config.col = maximised_col
	win_config.height = maximised_height
	win_config.width = maximised_width

	-- apply the new configuration
	vim.api.nvim_win_set_config(0, win_config)
end

function M.restore()
	if M.is_maximised() then
		local win_config = vim.api.nvim_win_get_config(0)
		win_config.row = original_row
		win_config.col = original_col
		win_config.height = original_height
		win_config.width = original_width
		vim.api.nvim_win_set_config(0, win_config)
		maximised_col = nil
		maximised_row = nil
		maximised_height = nil
		maximised_width = nil
	end
end

function M.toggle_maximise()
	if M.is_maximised() then
		M.restore()
	else
		M.maximise()
	end
end

return M
