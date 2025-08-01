local autocommands = require("config.autocommands")
local dap = require("dap")
local dap_utils = require("utils.dap")
local mappings = require("config.mappings")

local config = function()
	-- set defaults
	dap.defaults.fallback.exception_breakpoints = "default"
	dap.defaults.fallback.terminal_win_cmd = dap_utils.open_terminal
	dap.defaults.fallback.switchbuf = "usevisible,useopen,uselast"

	-- python
	local python_debugger_path = vim.g.python3_host_prog
	local python_path = vim.fn.exepath("python") ~= "" and vim.fn.exepath("python") or vim.fn.exepath("python3") -- use the path for "python", if it exists, else use the path for "python3"
	dap.adapters["python"] = {
		type = "executable",
		command = python_debugger_path,
		args = { "-m", "debugpy.adapter" },
		options = {
			source_filetype = "python",
		},
	}
	dap.configurations["python"] = {
		{
			type = "python",
			request = "launch",
			name = "Launch file from workspace",
			program = "${file}",
			cwd = "${workspaceFolder}",
			console = "integratedTerminal",
			pythonPath = python_path,
			env = { PYTHONPATH = "${workspaceFolder}" },
			justMyCode = false, -- enable debugging of third party packages
		},
	}

	-- typescript / javscript
	dap.defaults["pwa-node"].exception_breakpoints = { "raised", "uncaught" }
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
	dap.configurations["typescript"] = {
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
		},
		{
			-- Debug using ts-node (not node), with the transpile-only option, to skip type checking
			type = "pwa-node",
			request = "launch",
			name = "Launch Current File (tsx)",
			runtimeExecutable = "tsx",
			program = "${file}",
			cwd = "${workspaceFolder}",
			outFiles = { "${workspaceFolder}/**/**/*", "!**/node_modules/**" },
			skipFiles = {
				"<node_internals>/**",
				"${workspaceFolder}/node_modules/**",
			},
			console = "integratedTerminal",
		},
		{
			-- Debug .test.ts files with jest
			type = "pwa-node",
			request = "launch",
			name = "Debug Test File (jest)",
			cwd = "${workspaceFolder}",
			runtimeArgs = {
				"--inspect-brk",
				"${workspaceFolder}/node_modules/jest/bin/jest.js",
				"--runInBand",
				"${file}",
			},
			console = "integratedTerminal",
		},
	}
	mappings.dap()
	autocommands.dap()
end

config()
