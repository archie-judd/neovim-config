local config = function()
	local neotest = require("neotest")
	local neotest_python = require("neotest-python")
	local mappings = require("config.mappings")
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
