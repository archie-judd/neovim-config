local M = {}

-- Variables to store the layout and maximised state
local original_win_configs = {}
local maximised = {}

local function maximise(win_id)
	local FLOAT_MAX_HEIGHT = 0.975
	local FLOAT_MAX_WIDTH = 0.975
	local cols = vim.o.columns
	local rows = vim.o.lines - 2

	-- get the current configuration of the floating window
	original_win_configs[win_id] = vim.api.nvim_win_get_config(0)
	local update_win_config = vim.api.nvim_win_get_config(0)
	if update_win_config.relative ~= "" then
		-- update the row and col to reposition the window
		update_win_config.row = math.floor(rows * (1 - FLOAT_MAX_HEIGHT) / 2)
		update_win_config.col = math.floor(cols * (1 - FLOAT_MAX_WIDTH) / 2)
		update_win_config.height = math.floor(rows * FLOAT_MAX_HEIGHT)
		update_win_config.width = math.floor(cols * FLOAT_MAX_WIDTH)
	else
		update_win_config.height = vim.o.lines
		update_win_config.width = vim.o.columns
	end
	-- apply the new configuration
	vim.api.nvim_win_set_config(0, update_win_config)
	maximised[win_id] = true
end

local function restore(win_id)
	local original_win_config = original_win_configs[win_id]
	vim.api.nvim_win_set_config(0, original_win_config)
	maximised[win_id] = false
	original_win_configs[win_id] = nil
end

function M.toggle_maximise()
	local win_id = vim.api.nvim_get_current_win()
	if maximised[win_id] then
		restore(win_id)
	else
		maximise(win_id)
	end
end

function M.restore_if_maximised()
	local win_id = vim.api.nvim_get_current_win()
	if maximised[win_id] then
		restore(win_id)
	end
end

return M
