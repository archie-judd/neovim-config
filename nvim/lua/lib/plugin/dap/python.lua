local dap = require("dap")

local M = {}

function M.setup()
	local python_debugger_path = vim.g.python3_host_prog
	local python_path = vim.fn.exepath("python") ~= "" and vim.fn.exepath("python") or vim.fn.exepath("python3")

	dap.adapters.python = {
		type = "executable",
		command = python_debugger_path,
		args = { "-m", "debugpy.adapter" },
		options = {
			source_filetype = "python",
		},
	}
	dap.configurations.python = {
		{
			type = "python",
			request = "launch",
			name = "Launch file from workspace",
			program = "${file}",
			cwd = "${workspaceFolder}",
			console = "integratedTerminal",
			pythonPath = python_path,
			env = { PYTHONPATH = "${workspaceFolder}", MPLBACKEND = "Agg" },
			justMyCode = true,
		},
	}
end

return M
