local M = {}

---@return boolean
function M.dap_is_active()
	local dap = require("dap")
	return dap.status ~= ""
end

function M.debug_with_repl()
	local dap = require("dap")
	if not M.dap_is_active() then
		dap.terminate()
	end
	local repl_width = math.floor(vim.o.columns * 0.4)
	local wincmd = string.format("%svsplit new", repl_width)
	dap.continue()
	dap.repl.open({}, wincmd)
end

function M.debug_closest_test_with_repl()
	local dap = require("dap")
	local neotest = require("neotest")
	if not M.dap_is_active() then
		dap.terminate()
	end
	local repl_width = math.floor(vim.o.columns * 0.4)
	local wincmd = string.format("%svsplit new", repl_width)
	neotest.run.run({ strategy = "dap" })
	dap.repl.open({}, wincmd)
end

function M.dap_close()
	local dap = require("dap")
	dap.terminate()
	dap.close()
	dap.repl.close()
end

-- Ensure that when dap restarts, the file buffer is reopened in a non-dap window
function M.dap_restart()
	local dap = require("dap")
	local tabpage = vim.api.nvim_get_current_tabpage()
	for _, win_nr in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
		local buf_nr = vim.api.nvim_win_get_buf(win_nr)
		local buf_name = vim.api.nvim_buf_get_name(buf_nr)
		if not string.match(buf_name, "%[dap%-terminal%]") and not string.match(buf_name, "%[dap%-repl%]") then
			vim.api.nvim_set_current_win(win_nr)
			dap.restart()
			return
		end
	end
	dap.restart()
end

return M
