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

	---@param yank_function fun(register: string | nil): nil
	---@return fun(opts: { args: string | nil }): nil
	local function mk_yank_with_register(yank_function)
		-- zero or one argument (the register)
		return function(opts)
			local register = opts.args
			if register == "" then
				register = nil
			end
			yank_function(register)
		end
	end

	vim.api.nvim_create_user_command(
		"YankAbsFilepath",
		mk_yank_with_register(yank_utils.yank_abs_filepath),
		{ nargs = "?" }
	)
	vim.api.nvim_create_user_command(
		"YankRelFilepath",
		mk_yank_with_register(yank_utils.yank_rel_filepath),
		{ nargs = "?" }
	)
	vim.api.nvim_create_user_command("YankFilename", mk_yank_with_register(yank_utils.yank_filename), { nargs = "?" })
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
		vim.cmd("DiffviewFileHistory --range=" .. target .. "..HEAD")
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

function M.tasks()
	local tasks = vim.env.TASKS_PATH
	vim.api.nvim_create_user_command("Tasks", function()
		vim.cmd("edit " .. tasks)
	end, {})
end

return M
