local M = {}

-- Variables to store the layout and maximised state
---@type table<number, vim.api.keyset.win_config>
local original_win_configs = {}
local maximised = {}

local function maximise(win_id)
	local FLOAT_MAX_HEIGHT = 0.975
	local FLOAT_MAX_WIDTH = 0.975
	local cols = vim.o.columns
	local rows = vim.o.lines - 2

	-- get the current configuration of the floating window

	local update_win_config = vim.api.nvim_win_get_config(win_id)

	if update_win_config.relative ~= "" then
		original_win_configs[win_id] = vim.api.nvim_win_get_config(win_id)
		-- update the row and col to reposition the window
		update_win_config.row = math.floor(rows * (1 - FLOAT_MAX_HEIGHT) / 2)
		update_win_config.col = math.floor(cols * (1 - FLOAT_MAX_WIDTH) / 2)
		update_win_config.height = math.floor(rows * FLOAT_MAX_HEIGHT)
		update_win_config.width = math.floor(cols * FLOAT_MAX_WIDTH)
	else
		for i, win_id_ in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
			original_win_configs[win_id_] = vim.api.nvim_win_get_config(win_id_)
		end
		update_win_config.height = vim.o.lines
		update_win_config.width = vim.o.columns
	end
	-- apply the new configuration
	vim.api.nvim_win_set_config(0, update_win_config)
	maximised[win_id] = true
end

local function restore(win_id)
	for win_id_, config in pairs(original_win_configs) do
		vim.api.nvim_win_set_config(win_id_, config)
	end
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
