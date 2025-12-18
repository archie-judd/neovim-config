local dap = require("dap")

local M = {}

local function build_sls_invoke_local_args()
	vim.fn.input({
		prompt = "Ensure you have set custom.esbuild.sourcemap to true in serverless.yml. Press Enter to continue.",
	})
	local stage
	local region
	vim.ui.select({
		"prod",
		"dev",
	}, {
		prompt = "Stage: ",
	}, function(item, _)
		stage = item or "dev"
	end)
	vim.ui.select({
		"us-west-1",
		"eu-west-1",
	}, {
		prompt = "Region: ",
	}, function(item, _)
		region = item or "us-west-1"
	end)
	local aws_profile = vim.fn.input({
		prompt = "AWS profile: ",
	})
	local function_name = vim.fn.input({
		prompt = "Function Name: ",
	})
	local event_path = vim.fn.input({
		prompt = "Event File Path (or empty for no event): ",
		default = "event.json",
	})
	local args = {
		"invoke",
		"local",
		"--stage",
		stage,
		"--aws-profile",
		aws_profile,
		"--region",
		region,
		"--function",
		function_name,
		"--verbose",
	}
	if event_path ~= "" then
		table.insert(args, "--path")
		table.insert(args, event_path)
	end
	vim.cmd("redraw")
	vim.notify("SLS Invoke Local Args: " .. table.concat(args, " "), vim.log.levels.INFO)
	return args
end

function M.setup()
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
			name = "Debug SLS Invoke Local (node + serverless)",
			cwd = "${workspaceFolder}",
			runtimeExecutable = "node",
			program = "${workspaceFolder}/node_modules/serverless/bin/serverless.js",
			args = build_sls_invoke_local_args,
			sourceMaps = true,
			outFiles = {
				"${workspaceFolder}/.esbuild/.build/**/*.js",
				"!**/node_modules/**",
			},
			skipFiles = {
				"<node_internals>/**",
				"**/node_modules/**",
			},
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
