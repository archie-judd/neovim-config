local M = {}

-- Variables to store the layout and maximised state
---@type table<number, vim.api.keyset.win_config>
local original_win_configs = {}
local maximised = {}
local saved_winrestcmd = nil

local function maximise(win_id)
	local FLOAT_MAX_HEIGHT = 0.975
	local FLOAT_MAX_WIDTH = 0.975
	local cols = vim.o.columns
	local rows = vim.o.lines - 2

	local win_config = vim.api.nvim_win_get_config(win_id)

	if win_config.relative ~= "" then
		original_win_configs[win_id] = vim.api.nvim_win_get_config(win_id)
		win_config.row = math.floor(rows * (1 - FLOAT_MAX_HEIGHT) / 2)
		win_config.col = math.floor(cols * (1 - FLOAT_MAX_WIDTH) / 2)
		win_config.height = math.floor(rows * FLOAT_MAX_HEIGHT)
		win_config.width = math.floor(cols * FLOAT_MAX_WIDTH)
		vim.api.nvim_win_set_config(win_id, win_config)
	else
		saved_winrestcmd = vim.fn.winrestcmd()
		vim.api.nvim_win_set_width(win_id, vim.o.columns)
		vim.api.nvim_win_set_height(win_id, vim.o.lines)
	end
	maximised[win_id] = true
end

local function restore(win_id)
	local win_config = vim.api.nvim_win_get_config(win_id)
	if win_config.relative ~= "" then
		for win_id_, config in pairs(original_win_configs) do
			vim.api.nvim_win_set_config(win_id_, config)
		end
		original_win_configs = {}
	else
		if saved_winrestcmd then
			vim.cmd(saved_winrestcmd)
			saved_winrestcmd = nil
		end
	end
	maximised[win_id] = false
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
