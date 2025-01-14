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

function M.debug_with_repl()
	if not M.dap_is_active() then
		dap.terminate()
	end
	local repl_width = math.floor(vim.o.columns * 0.4)
	local wincmd = string.format("%svsplit new", repl_width)
	dap.continue()
	dap.repl.open({}, wincmd)
end

function M.debug_closest_test_with_repl()
	if not M.dap_is_active() then
		dap.terminate()
	end
	local repl_width = math.floor(vim.o.columns * 0.4)
	local wincmd = string.format("%svsplit new", repl_width)
	neotest.run.run({ strategy = "dap" })
	dap.repl.open({}, wincmd)
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
