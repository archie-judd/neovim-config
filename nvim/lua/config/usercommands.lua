local M = {}

function M.cmp()
	vim.api.nvim_create_user_command("CmpStop", function()
		vim.g.cmp_enabled = false
	end, { nargs = 0 })
	vim.api.nvim_create_user_command("CmpStart", function()
		vim.g.cmp_enabled = true
	end, { nargs = 0 })
end

function M.github_link()
	local github_link = require("lib.plugin.github_link")
	vim.api.nvim_create_user_command("GitHubLink", function(opts)
		---@type string | nil
		local rev = opts.args
		if rev == "" then
			rev = nil
		end
		local range = opts.range ~= 0
		github_link.github_link({ rev = rev, remote = "origin", range = range })
	end, { nargs = "?", range = true })
end

function M.clear_registers()
	local clear_registers = require("lib.plugin.clear_registers")
	vim.api.nvim_create_user_command("ClearRegisters", function(opts)
		---@type table<string>
		local registers = {}
		local regstring = opts.args:gsub("%s+", "")
		for i = 1, #regstring do
			table.insert(registers, regstring:sub(i, i))
		end
		clear_registers.clear_registers(unpack(registers))
	end, { nargs = 1 })
end

function M.yank_filepath()
	local yank_utils = require("lib.plugin.yank")

	---@param yank_function fun(register: string | nil, range: boolean): nil
	---@return fun(opts: { args: string | nil, range: number }): nil
	local function mk_yank_with_register(yank_function)
		-- zero or one argument (the register)
		return function(opts)
			local register = opts.args
			if register == "" then
				register = nil
			end
			yank_function(register, opts.range ~= 0)
		end
	end

	vim.api.nvim_create_user_command(
		"YankAbsFilepath",
		mk_yank_with_register(yank_utils.yank_abs_filepath),
		{ nargs = "?", range = true }
	)
	vim.api.nvim_create_user_command(
		"YankRelFilepath",
		mk_yank_with_register(yank_utils.yank_rel_filepath),
		{ nargs = "?", range = true }
	)
	vim.api.nvim_create_user_command(
		"YankFilename",
		mk_yank_with_register(yank_utils.yank_filename),
		{ nargs = "?", range = true }
	)
end

function M.diff()
	local gitsigns = require("gitsigns")
	local lazy_load_util = require("lib.lazy_load")
	local lib = require("lib.plugin.diff")

	vim.api.nvim_create_user_command("Diff", function(opts)
		local ref = opts.args ~= "" and opts.args or nil
		local target = lib.resolve_ref(ref, not opts.bang)
		if not target then
			return
		end
		lazy_load_util.ensure_loaded("diffview")
		gitsigns.change_base(target, true)
		vim.cmd("DiffviewOpen " .. target)
	end, {
		bang = true,
		nargs = "?",
		complete = function()
			return vim.fn.systemlist("git branch -a --format='%(refname:short)'")
		end,
	})

	vim.api.nvim_create_user_command("DiffClose", function()
		lib.close_diffview_tabs()
		gitsigns.change_base(nil, true)
	end, {})
end

function M.stage()
	local gitsigns = require("gitsigns")

	vim.api.nvim_create_user_command("Stage", function(opts)
		if opts.range ~= 0 then
			gitsigns.stage_hunk({ opts.line1, opts.line2 })
		else
			gitsigns.stage_hunk()
		end
	end, { range = true })
end

function M.tasks()
	local tasks = vim.env.TASKS_PATH
	vim.api.nvim_create_user_command("Tasks", function()
		vim.cmd("edit " .. tasks)
	end, {})
end

function M.log()
	local log = vim.env.LOG_PATH
	vim.api.nvim_create_user_command("Log", function()
		vim.cmd("edit " .. log)
	end, {})
end

function M.markdown_log()
	vim.api.nvim_buf_create_user_command(0, "LogEntry", function()
		local timestamp = os.date("%Y-%m-%d")
		local new_lines = { "", "## " .. timestamp, "", "" }
		local row = vim.api.nvim_buf_line_count(0)
		vim.api.nvim_buf_set_lines(0, row, row, false, new_lines)
		vim.api.nvim_win_set_cursor(0, { row + #new_lines, 0 })
		vim.cmd("startinsert!")
	end, {})
end

function M.dap()
	local core_utils = require("lib.core")
	local dap = require("dap")
	local sls = require("lib.plugin.dap.sls")
	local telescope = require("telescope")

	vim.api.nvim_create_user_command("DapDebugSls", function()
		sls.debug()
	end, {})
	vim.api.nvim_create_user_command("DapBreakpoint", function()
		dap.set_breakpoint(
			core_utils.user_input_or_nil("Condition (default is always stop): "),
			core_utils.user_input_or_nil("Number of hits to trigger (default is zero): "),
			core_utils.user_input_or_nil("Log message (default is none): ")
		)
	end, {})
	vim.api.nvim_create_user_command("DapClearBreakpoints", function()
		dap.clear_breakpoints()
	end, {})
	vim.api.nvim_create_user_command("DapCommands", function()
		telescope.extensions.dap.dap_commands()
	end, {})
end

function M.telescope()
	local telescope_builtin = require("telescope.builtin")

	vim.api.nvim_create_user_command("Keymaps", function()
		telescope_builtin.keymaps()
	end, {})
	vim.api.nvim_create_user_command("Commands", function()
		telescope_builtin.commands()
	end, {})
	vim.api.nvim_create_user_command("QuickfixHistory", function()
		telescope_builtin.quickfixhistory()
	end, {})
end

function M.diffview()
	local diffview_utils = require("lib.plugin.diffview")

	vim.api.nvim_create_user_command("DiffHistory", function()
		diffview_utils.open_diffview_file_history()
	end, {})
end

function M.neotest()
	local neotest = require("neotest")

	vim.api.nvim_create_user_command("TestFile", function()
		neotest.run.run(vim.fn.expand("%"))
	end, {})
end

return M
