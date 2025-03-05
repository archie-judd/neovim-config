local core_utils = require("utils.core")
local dap = require("dap")
local neotest = require("neotest")

local M = {}

---@param opts table | nil
---@return string | nil
local function try_to_get_debugged_filepath(opts)
	opts = opts or {}
	local session = opts.session or dap.session()
	local debugged_filepath = nil
	if session ~= nil then
		debugged_filepath = session.program
		if debugged_filepath == nil and session.current ~= nil then
			debugged_filepath = session.current_frame.source.path
		end
	end
	return debugged_filepath
end

---@param opts table
---@return integer | nil
function M.try_to_get_debugged_bufnr(opts)
	local debugged_bufnr = nil
	local debugged_filepath = try_to_get_debugged_filepath(opts)
	if debugged_filepath ~= nil then
		debugged_bufnr = vim.fn.bufnr(debugged_filepath)
	end
	return debugged_bufnr
end

function M.move_to_current_frame()
	local session = dap.session()
	local current_frame = session.current_frame
	local bufnr = M.try_to_get_debugged_bufnr({ session = session })
	if bufnr ~= nil then
		local debugged_winnr = core_utils.get_winnr_for_bufnr(bufnr)
		if debugged_winnr ~= nil then
			vim.api.nvim_set_current_win(debugged_winnr)
			if current_frame ~= nil then
				local line_number = session.current_frame.line
				local column_number = session.current_frame.column
				vim.api.nvim_win_set_cursor(debugged_winnr, { line_number, column_number })
			end
		end
	end
end

---@param opts table | nil
---@return integer | nil
function M.try_to_move_to_debugged_buf(opts)
	opts = opts or {}
	local debugged_bufnr = M.try_to_get_debugged_bufnr(opts)
	if debugged_bufnr ~= nil then
		local debugged_winnr = core_utils.get_winnr_for_bufnr(debugged_bufnr)
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
	dap.continue()
end

---@param buf integer
local function open_terminal_window(buf)
	local TERMINAL_WIDTH = 0.4
	local width = math.floor(vim.o.columns * TERMINAL_WIDTH)
	vim.cmd("vsplit")
	vim.cmd("vertical resize " .. width)
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)
	return win
end

function M.open_terminal()
	local buf = vim.api.nvim_create_buf(false, true) -- Create a new buffer (no file, scratch)
	local win = open_terminal_window(buf)
	return buf, win
end

function M.open_repl_window()
	local repl_buf = core_utils.get_bufnr_by_pattern("dap%-repl")
	if repl_buf == nil or not vim.api.nvim_buf_is_valid(repl_buf) then
		dap.repl.open(nil)
		repl_buf = core_utils.get_bufnr_by_pattern("dap%-repl")
	end
	if repl_buf ~= nil and vim.api.nvim_buf_is_valid(repl_buf) then
		local repl_win = core_utils.get_winnr_for_bufnr(repl_buf)
		if repl_win ~= nil and vim.api.nvim_win_is_valid(repl_win) then
			vim.api.nvim_win_close(repl_win, true)
		end
		local term_buf = core_utils.get_bufnr_by_pattern("%[dap%-terminal%]")
		if term_buf ~= nil and vim.api.nvim_buf_is_valid(term_buf) then
			local term_win = core_utils.get_winnr_for_bufnr(term_buf)
			if term_win ~= nil and vim.api.nvim_win_is_valid(term_win) then
				vim.api.nvim_set_current_win(term_win)
				vim.cmd("split")
				vim.api.nvim_win_set_buf(0, repl_buf)
				return vim.api.nvim_get_current_win()
			end
		end
	end
end

function M.open_terminal_window()
	local TERM_WIDTH = 0.4
	local term_buf = core_utils.get_bufnr_by_pattern("%[dap%-terminal%]")
	local term_win = nil
	if term_buf ~= nil and vim.api.nvim_buf_is_valid(term_buf) then
		term_win = core_utils.get_winnr_for_bufnr(term_buf)
		if term_win ~= nil and vim.api.nvim_win_is_valid(term_win) then
			vim.api.nvim_set_current_win(term_win)
		else
			vim.cmd("vsplit")
			vim.cmd("vertical resize " .. TERM_WIDTH)
		end
	end
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
	if dap_repl_bufnr ~= nil then
		vim.api.nvim_buf_delete(dap_repl_bufnr, { force = true })
	end
	if dap_term_bufnr ~= nil then
		vim.api.nvim_buf_delete(dap_term_bufnr, { force = true })
	end
	dap.terminate()
	dap.close()
	dap.repl.close()
end

-- Ensure that dap debugged window is focussed before running the command
function M.dap_restart()
	M.try_to_move_to_debugged_buf()
	local session = dap.session()
	if session ~= nil then
		dap.restart()
	else
		dap.continue()
	end
end

function M.dap_continue()
	M.try_to_move_to_debugged_buf()
	dap.continue()
end

function M.step_over()
	M.try_to_move_to_debugged_buf()
	dap.step_over()
end

function M.step_into()
	M.try_to_move_to_debugged_buf()
	dap.step_into()
end

function M.step_out()
	M.try_to_move_to_debugged_buf()
	dap.step_out()
end

return M
