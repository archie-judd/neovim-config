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

return M
