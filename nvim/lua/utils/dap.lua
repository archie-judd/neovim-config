local core_utils = require("utils.core")
local dap = require("dap")
local neotest = require("neotest")

local M = {}

vim.g.debugged_bufnr = nil

function M.move_to_current_frame()
	local session = dap.session()
	local current_frame = session.current_frame
	if vim.g.debugged_bufnr ~= nil and vim.api.nvim_buf_is_valid(vim.g.debugged_bufnr) then
		local debugged_winnr = core_utils.get_winnr_for_bufnr(vim.g.debugged_bufnr)
		if debugged_winnr ~= nil and vim.api.nvim_win_is_valid(debugged_winnr) then
			vim.api.nvim_set_current_win(debugged_winnr)
			if current_frame ~= nil then
				local line_number = session.current_frame.line
				local column_number = session.current_frame.column
				vim.api.nvim_win_set_cursor(debugged_winnr, { line_number, column_number })
			end
		end
	end
end

---@return integer | nil
local function try_to_move_to_debugged_buf()
	if vim.g.debugged_bufnr ~= nil and vim.api.nvim_buf_is_valid(vim.g.debugged_bufnr) then
		local debugged_winnr = core_utils.get_winnr_for_bufnr(vim.g.debugged_bufnr)
		if debugged_winnr ~= nil then
			vim.api.nvim_set_current_win(debugged_winnr)
			return debugged_winnr
		end
	end
end

---@return boolean
function M.dap_is_active()
	return dap.status ~= ""
end

function M.debug()
	if not M.dap_is_active() then
		dap.terminate()
	end
	vim.g.debugged_bufnr = vim.api.nvim_get_current_buf()
	dap.continue()
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
	if not M.dap_is_active() then
		dap.terminate()
	end
	neotest.run.run({ strategy = "dap" })
end

function M.dap_quit()
	local dap_repl_bufnr = core_utils.get_bufnr_by_pattern("%[dap%-repl%]")
	local dap_term_bufnr = core_utils.get_bufnr_by_pattern("%[dap%-terminal%]")
	if dap_repl_bufnr ~= nil and vim.api.nvim_buf_is_valid(dap_repl_bufnr) then
		vim.api.nvim_buf_delete(dap_repl_bufnr, { force = true })
	end
	if dap_term_bufnr ~= nil and vim.api.nvim_buf_is_valid(dap_term_bufnr) then
		vim.api.nvim_buf_delete(dap_term_bufnr, { force = true })
	end
	dap.terminate()
	dap.close()
	dap.repl.close()
	vim.g.debugged_bufnr = nil
end

-- Ensure that dap debugged window is focussed before running the command
function M.dap_restart()
	try_to_move_to_debugged_buf()
	local session = dap.session()
	if session ~= nil then
		dap.restart()
	else
		dap.continue()
	end
end

function M.dap_continue()
	local session = dap.session()
	-- only continue if there is a session
	if session ~= nil then
		try_to_move_to_debugged_buf()
		dap.continue()
	end
end

function M.step_over()
	try_to_move_to_debugged_buf()
	dap.step_over()
end

function M.step_into()
	try_to_move_to_debugged_buf()
	dap.step_into()
end

function M.step_out()
	try_to_move_to_debugged_buf()
	dap.step_out()
end

return M
