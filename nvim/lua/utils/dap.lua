local core_utils = require("utils.core")
local dap = require("dap")
local neotest = require("neotest")

local M = {}

---@param opts table
local function try_to_get_debugged_filepath(opts)
	local session = opts.session or dap.session()
	local debugged_filepath = nil
	if session ~= nil then
		debugged_filepath = session.program
		if debugged_filepath == nil then
			debugged_filepath = session.current_frame.source.path
		end
	end
	return debugged_filepath
end

---@param opts table
---@return integer | nil
function M.get_debugged_bufnr(opts)
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
	local bufnr = M.get_debugged_bufnr({ session = session })
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

---@return integer | nil
function M.try_to_move_to_debugged_buf(opts)
	local debugged_bufnr = M.get_debugged_bufnr(opts)
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
local function open_floating_terminal_window(buf)
	local available_height = vim.o.lines - vim.o.cmdheight - 2
	local available_width = vim.o.columns
	local width = math.floor(available_width * 0.48)
	local height = math.floor(available_height * 0.48)
	local col = math.floor(3 * (vim.o.columns / 4))
	local row = math.ceil(2 + (available_height / 2))

	-- Create the floating window with the terminal
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal", -- No borders or title
		border = "single", -- Add border (optional)
		title = "DAP Terminal",
		title_pos = "center",
		zindex = 50,
	})
	return win
end

---@param buf integer
local function open_repl_window(buf)
	local available_height = vim.o.lines - vim.o.cmdheight - 2
	local width = math.floor(vim.o.columns * 0.48)
	local height = math.floor(available_height * 0.48)
	local row = 0
	local col = math.floor(3 * (vim.o.columns / 4))
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "single",
		title = "DAP REPL",
		title_pos = "center",
		zindex = 50,
	}

	-- Create the floating window
	local win = vim.api.nvim_open_win(buf, true, opts)
	return win
end

function M.open_floating_terminal()
	local buf = vim.api.nvim_create_buf(false, true) -- Create a new buffer (no file, scratch)
	local win = open_floating_terminal_window(buf)
	return buf, win
end

function M.open_repl_floating_window()
	local repl_buf = core_utils.get_bufnr_by_pattern("dap%-repl")
	local repl_win = nil
	-- If open, focus the window
	if repl_buf ~= nil and vim.api.nvim_buf_is_valid(repl_buf) then
		repl_win = core_utils.get_winnr_for_bufnr(repl_buf)
		if repl_win ~= nil and vim.api.nvim_win_is_valid(repl_win) then
			vim.api.nvim_set_current_win(repl_win)
		else
			open_repl_window(repl_buf)
		end
	else
		dap.repl.open(nil)
		repl_buf = core_utils.get_bufnr_by_pattern("dap%-repl")
		if repl_buf ~= nil and vim.api.nvim_buf_is_valid(repl_buf) then
			repl_win = core_utils.get_winnr_for_bufnr(repl_buf)
			if repl_win ~= nil and vim.api.nvim_win_is_valid(repl_win) then
				vim.api.nvim_win_close(repl_win, true)
				open_repl_window(repl_buf)
			end
		end
	end
end

function M.open_terminal_floating_window()
	local term_buf = core_utils.get_bufnr_by_pattern("%[dap%-terminal%]")
	local term_win = nil
	if term_buf ~= nil and vim.api.nvim_buf_is_valid(term_buf) then
		term_win = core_utils.get_winnr_for_bufnr(term_buf)
		if term_win ~= nil and vim.api.nvim_win_is_valid(term_win) then
			vim.api.nvim_set_current_win(term_win)
		else
			open_floating_terminal_window(term_buf)
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
