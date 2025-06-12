local core_utils = require("utils.core")
local dap = require("dap")
local diffview = require("diffview")
local neotest = require("neotest")

local M = {}

vim.g.debugged_winnr = nil

---@return boolean
local function dap_is_active()
	return dap.session() ~= nil
end

local function move_to_current_frame()
	local session = dap.session()
	local current_frame = session.current_frame
	if vim.g.debugged_winnr ~= nil and vim.api.nvim_win_is_valid(vim.g.debugged_winnr) then
		vim.api.nvim_set_current_win(vim.g.debugged_winnr)
		if current_frame ~= nil then
			local line_number = session.current_frame.line
			local column_number = session.current_frame.column
			vim.api.nvim_win_set_cursor(vim.g.debugged_winnr, { line_number, column_number })
		end
	end
end

function M.start()
	-- If diffview is open, close it before starting a debug session
	diffview.close()
	if not dap_is_active() then
		vim.notify("Starting debug session", vim.log.levels.INFO)
		vim.g.debugged_winnr = vim.api.nvim_get_current_win()
		dap.continue()
	else
		vim.notify("Debug session already active", vim.log.levels.INFO)
	end
end

function M.quit()
	vim.notify("Closing debug session", vim.log.levels.INFO)
	local dap_term_bufnr = core_utils.get_bufnr_by_pattern("%[dap%-terminal%]")
	if dap_term_bufnr ~= nil and vim.api.nvim_buf_is_valid(dap_term_bufnr) then
		vim.api.nvim_buf_delete(dap_term_bufnr, { force = true })
	end
	dap.repl.close()
	if dap_is_active() then
		dap.terminate()
		dap.close()
	else
	end
	vim.g.debugged_winnr = nil
end

function M.open_terminal()
	local TERMINAL_WIDTH = 0.4
	local buf = vim.api.nvim_create_buf(false, true) -- Create a new buffer (no file, scratch)
	local width = math.floor(vim.o.columns * TERMINAL_WIDTH)
	vim.cmd("vsplit")
	vim.cmd("vertical resize " .. width)
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)
	return buf, win
end

function M.debug_closest_test()
	if dap_is_active() then
		vim.notify("Cannot debug test, debug session already active", vim.log.levels.INFO)
	else
		vim.notify("Debugging test", vim.log.levels.INFO)
		vim.g.debugged_winnr = vim.api.nvim_get_current_win()
		neotest.run.run({ strategy = "dap" })
	end
end

-- Ensure that dap debugged window is focussed before running the command
function M.dap_restart()
	if dap_is_active() then
		vim.notify("Restarting debug session", vim.log.levels.INFO)
		if vim.api.nvim_win_is_valid(vim.g.debugged_winnr) then
			vim.api.nvim_set_current_win(vim.g.debugged_winnr)
			dap.restart()
		else
			vim.notify("Cannot find debug window", vim.log.levels.INFO)
		end
	else
		vim.notify("Cannot restart - no active debug session", vim.log.levels.INFO)
	end
end

function M.dap_continue()
	if dap_is_active() then
		if vim.api.nvim_win_is_valid(vim.g.debugged_winnr) then
			vim.api.nvim_set_current_win(vim.g.debugged_winnr)
			dap.continue()
		else
			vim.notify("Cannot find debug window", vim.log.levels.INFO)
		end
	else
		vim.notify("Cannot continue - no active debug session", vim.log.levels.INFO)
	end
end

function M.step_over()
	if dap_is_active() then
		if vim.api.nvim_win_is_valid(vim.g.debugged_winnr) then
			vim.api.nvim_set_current_win(vim.g.debugged_winnr)
			dap.step_over()
		else
			vim.notify("Cannot find debug window", vim.log.levels.INFO)
		end
	else
		vim.notify("Cannot step over - no active debug session", vim.log.levels.INFO)
	end
end

function M.step_into()
	if dap_is_active() then
		if vim.api.nvim_win_is_valid(vim.g.debugged_winnr) then
			vim.api.nvim_set_current_win(vim.g.debugged_winnr)
			dap.step_into()
		else
			vim.notify("Cannot find debug window", vim.log.levels.INFO)
		end
	else
		vim.notify("Cannot step into - no active debug session", vim.log.levels.INFO)
	end
end

function M.step_out()
	if dap_is_active() then
		if vim.api.nvim_win_is_valid(vim.g.debugged_winnr) then
			vim.api.nvim_set_current_win(vim.g.debugged_winnr)
			dap.step_out()
		else
			vim.notify("Cannot find debug window", vim.log.levels.INFO)
		end
	else
		vim.notify("Cannout step out - no active debug session", vim.log.levels.INFO)
	end
end

function M.move_to_current_frame()
	if dap_is_active() then
		move_to_current_frame()
	else
		vim.notify("Cannot move to current frame - no active debug session", vim.log.levels.INFO)
	end
end

return M
