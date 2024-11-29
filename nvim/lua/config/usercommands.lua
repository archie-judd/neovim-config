local clear_registers = require("clear_registers")
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

function M.clear_registers()
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

return M
