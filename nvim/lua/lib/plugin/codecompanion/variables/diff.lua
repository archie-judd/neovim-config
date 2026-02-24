local config = require("codecompanion.config")

local Variable = {}

---@param args table
function Variable.new(args)
	return setmetatable({
		Chat = args.Chat,
		config = args.config,
		params = args.params, -- This is where :main ends up
	}, { __index = Variable })
end

---The output method must accept these arguments to be fully compatible
function Variable:output()
	local base = self.params
	local diff
	if base and base ~= "" then
		diff = vim.fn.system("git diff " .. base .. "...HEAD")
	else
		diff = vim.fn.system("git diff")
	end
	if not diff or diff == "" then
		vim.notify("No diff found", vim.log.levels.WARN)
		return
	end
	diff = string.format("```diff\n%s\n```", diff)
	self.Chat:add_message({
		role = config.constants.USER_ROLE,
		content = diff,
	}, { tag = "variable", visible = true })
end

return Variable
