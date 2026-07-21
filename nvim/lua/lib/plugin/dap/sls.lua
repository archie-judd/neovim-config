local dap = require("dap")

local M = {}

local selection_cache = {}

local function args_to_string(args)
	return table.concat(args, " ")
end

local function selection_to_string(selection)
	return selection.stack_path .. " | " .. args_to_string(selection.args)
end

local function to_absolute_path(path)
	if path == "" or vim.startswith(path, "/") then
		return path
	end
	return vim.fs.joinpath(vim.fn.getcwd(), path)
end

---@return table|nil
local function maybe_get_cached_selection()
	local selection = nil
	local use_cached_selection = false
	vim.ui.select({
		"Yes",
		"No",
	}, {
		prompt = "Use cached SLS Invoke Local selection? ",
	}, function(item, _)
		use_cached_selection = item == "Yes"
	end)
	if use_cached_selection then
		local selection_strings = {}
		for idx, cached_selection in ipairs(selection_cache) do
			table.insert(selection_strings, idx, selection_to_string(cached_selection))
		end
		vim.ui.select(selection_strings, {
			prompt = "Select cached selection: ",
		}, function(_, idx)
			selection = selection_cache[idx]
		end)
		return selection
	end
end

local function cache_selection(selection)
	local selection_string = selection_to_string(selection)
	local is_duplicate = false
	for _, cached in ipairs(selection_cache) do
		if selection_to_string(cached) == selection_string then
			is_duplicate = true
			break
		end
	end
	if not is_duplicate then
		table.insert(selection_cache, selection)
	end
end

local function build_selection()
	vim.fn.input({
		prompt = "Ensure you have set custom.esbuild.sourcemap to true in serverless.yml. Press Enter to continue.",
	})
	local stack_path = vim.fn.input({
		prompt = "Stack path (relative to workspace root, e.g. stacks/foo): ",
		completion = "dir",
	})
	vim.cmd("redraw")
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
	local event_path = to_absolute_path(vim.fn.input({
		prompt = "Event File Path (or empty for no event): ",
		completion = "file",
	}))
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
	local selection = { stack_path = stack_path, args = args }
	cache_selection(selection)
	vim.cmd("redraw")
	vim.notify("SLS Invoke Local Selection: " .. selection_to_string(selection), vim.log.levels.INFO)
	return selection
end

local function get_selection()
	local selection = nil
	if #selection_cache > 0 then
		selection = maybe_get_cached_selection()
	end
	if selection == nil then
		selection = build_selection()
	end
	return selection
end

function M.debug()
	local selection = get_selection()
	local stack_cwd = vim.fs.joinpath(vim.fn.getcwd(), selection.stack_path)
	local config = {
		type = "pwa-node",
		request = "launch",
		name = "Debug SLS Invoke Local (node + osls)",
		cwd = stack_cwd,
		runtimeExecutable = "node",
		program = vim.fs.joinpath(stack_cwd, "node_modules/osls/bin/serverless.js"),
		args = selection.args,
		sourceMaps = true,
		outFiles = {
			vim.fs.joinpath(stack_cwd, ".esbuild/.build/**/*.js"),
			"!**/node_modules/**",
		},
		skipFiles = {
			"<node_internals>/**",
			"**/node_modules/**",
		},
		console = "integratedTerminal",
		outputCapture = "none",
	}
	vim.notify("Starting DAP Debugging for SLS Invoke Local with config: " .. vim.inspect(config), vim.log.levels.INFO)
	dap.run(config)
end

return M
