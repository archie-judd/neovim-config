local mappings = require("config.mappings")
local neotest = require("neotest")
local neotest_python = require("neotest-python")

local config = function()
	local python_path = vim.fn.exepath("python") ~= "" and vim.fn.exepath("python") or vim.fn.exepath("python3")
	neotest.setup({
		adapters = {
			neotest_python({
				dap = {
					cwd = "${workspaceFolder}",
					env = { PYTHONPATH = "${workspaceFolder}", MPLBACKEND = "Agg" },
					console = "integratedTerminal",
					justMyCode = false, -- enable debugging of third party packages
				},
				runner = "pytest",
				args = { "-s" }, -- disable output capture
				python = python_path,
			}),
		},
	})
	mappings.neotest()
end

config()
