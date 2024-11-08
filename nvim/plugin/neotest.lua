local mappings = require("config.mappings")
local neotest = require("neotest")
local neotest_python = require("neotest-python")

local config = function()
	neotest.setup({
		adapters = {
			neotest_python({
				dap = {
					cwd = "${workspaceFolder}",
					env = { PYTHONPATH = "${workspaceFolder}" },
					console = "integratedTerminal",
					justMyCode = false, -- enable debugging of third party packages
				},
			}),
		},
	})
	mappings.neotest()
end

config()
