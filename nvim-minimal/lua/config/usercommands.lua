local M = {}

function M.yank_filepath()
	local yank_utils = require("lib.plugin.yank")

	---@param yank_function fun(register: string | nil, range: boolean): nil
	---@return fun(opts: { args: string | nil, range: number }): nil
	local function mk_yank_with_register(yank_function)
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

return M
