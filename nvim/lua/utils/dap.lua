local M = {}

---@return boolean
function M.dap_is_active()
	return require("dap").status ~= ""
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

return M
