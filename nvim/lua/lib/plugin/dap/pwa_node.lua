local dap = require("dap")

local M = {}

function M.setup()
	dap.defaults["pwa-node"].exception_breakpoints = { "uncaught", "caught" }
	local js_debug_path = vim.fs.joinpath(
		vim.fs.root(vim.fn.exepath("js-debug"), "lib"),
		"lib/node_modules/js-debug/dist/src/dapDebugServer.js"
	)
	dap.adapters["pwa-node"] = {
		type = "server",
		host = "localhost",
		port = "${port}",
		executable = {
			command = "node",
			args = {
				js_debug_path,
				"${port}",
			},
		},
	}

	dap.configurations.typescript = {
		{
			type = "pwa-node",
			request = "launch",
			name = "Launch Current File (node)",
			cwd = "${workspaceFolder}",
			program = "${file}",
			outFiles = { "${workspaceFolder}/**/**/*", "!**/node_modules/**" },
			skipFiles = { "<node_internals>/**", "node_modules/**" },
			sourceMaps = true,
			console = "integratedTerminal",
			outputCapture = "none",
		},
		{
			type = "pwa-node",
			request = "launch",
			name = "Launch Current File (tsx)",
			runtimeExecutable = "tsx",
			program = "${file}",
			cwd = "${workspaceFolder}",
			skipFiles = {
				"<node_internals>/**",
				"${workspaceFolder}/node_modules/**",
			},
			sourceMaps = true,
			console = "integratedTerminal",
			outputCapture = "none",
		},
		{
			type = "pwa-node",
			request = "launch",
			name = "Debug Test File (node + jest)",
			cwd = "${workspaceFolder}",
			runtimeExecutable = "node",
			program = "${workspaceFolder}/node_modules/jest/bin/jest.js",
			args = {
				"--runInBand",
				"${file}",
			},
			skipFiles = {
				"<node_internals>/**",
				"**/node_modules/**",
			},
			console = "integratedTerminal",
			outputCapture = "none",
		},
	}
end

return M
