local github_link = require("github_link")

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
	vim.api.nvim_create_user_command("GitHubLink", function(opts)
		---@type string | nil
		local branch = opts.args
		if branch == "" then
			branch = nil
		end
		local range = opts.range ~= 0
		github_link.github_link({ branch = branch, range = range })
	end, { nargs = "?", range = true })
end

return M
