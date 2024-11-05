local M = {}

function M.cmp()
	vim.api.nvim_create_user_command("CmpStop", function()
		vim.g.cmp_enabled = false
	end, { nargs = 0 })
	vim.api.nvim_create_user_command("CmpStart", function()
		vim.g.cmp_enabled = true
	end, { nargs = 0 })
end

return M
