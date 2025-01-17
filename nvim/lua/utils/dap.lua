local core_utils = require("utils.core")
local dap = require("dap")
local neotest = require("neotest")

local M = {}

---@return integer | nil
function M.get_debugged_bufnr()
	local session = dap.session()
	local debugged_bufnr = nil
	if session ~= nil then
		local debugged_filepath = session.config.program
		if debugged_filepath ~= nil then
			debugged_bufnr = core_utils.get_bufnr_by_absolute_path(debugged_filepath)
		end
	end
	return debugged_bufnr
end

function M.try_to_move_to_debugged_buf()
	local debugged_bufnr = M.get_debugged_bufnr()
	if debugged_bufnr ~= nil then
		local debugged_winnr = core_utils.get_winnr_for_bufnr(debugged_bufnr)
		if debugged_winnr ~= nil then
			vim.api.nvim_set_current_win(debugged_winnr)
		else
			for _, winnr in ipairs(vim.api.nvim_tabpage_list_wins(vim.api.nvim_get_current_tabpage())) do
				local bufnr = vim.api.nvim_win_get_buf(winnr)
				local bufname = vim.api.nvim_buf_get_name(bufnr)
				if
					string.match(bufname, "%[dap%-repl%]") == nil
					and string.match(bufname, "%[dap%-terminal%]") == nil
				then
					break
				end
			end
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
	dap.restart()
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
