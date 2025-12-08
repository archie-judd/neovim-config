local config = function()
	local mappings = require("config.mappings")
	local neotest = require("neotest")
	local neotest_python = require("neotest-python")
	local neotest_vitest = require("neotest-vitest")

	vim.g.maplocalleader = ","

	local python_path = vim.fn.exepath("python") ~= "" and vim.fn.exepath("python") or vim.fn.exepath("python3")
	neotest.setup({
		adapters = {
			neotest_python({
				dap = {
					cwd = "${workspaceFolder}",
					env = {
						PYTHONPATH = "${workspaceFolder}",
						MPLBACKEND = "Agg",
						-- Disable Python 3.12+ sys.monitoring optimization (PEP 669).
						-- This forces debugpy to use the legacy sys.settrace mechanism,
						-- ensuring the debugger pauses at the source of the error
						-- rather than inside Pytest's internal context manager.
						PYDEVD_USE_SYS_MONITORING = "0",
					},
					console = "integratedTerminal",
					justMyCode = true,
				},
				runner = "pytest",
				args = { "-s" }, -- disable output capture
				python = python_path,
			}),
			neotest_vitest({}),
		},
	})
	mappings.neotest()
end

local function load_on_keymap()
	local lazy_load_util = require("utils.lazy_load")

	local function action()
		require("neotest").run.run()
	end

	lazy_load_util.load_plugin_on_keymap(
		"neotest",
		{ "n" },
		"<Leader>rt",
		{ desc = "Lazy load: neotest", silent = true, noremap = true },
		config,
		action
	)
end

load_on_keymap()
