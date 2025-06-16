local codecompanion = require("codecompanion")
local config = require("codecompanion.config")
local context_utils = require("codecompanion.utils.context")

local M = {}

---@param opts table
---@return table
function M.open(opts)
	opts = opts or {}
	local chat = codecompanion.last_chat()

	if not chat then
		chat = codecompanion.chat()
	else
		if chat.ui:is_visible() then
			if opts.new then
				codecompanion.close_last_chat()
				chat = codecompanion.chat()
			end
		else
			if opts.new then
				chat = codecompanion.chat()
			else
				chat.ui:open()
			end
		end
	end
	return chat
end

---@param opts table
function M.add_selection(opts)
	opts = opts or {}
	local context = context_utils.get(vim.api.nvim_get_current_buf(), nil)
	local content = table.concat(context.lines, "\n")
	vim.cmd("normal! <Esc>")
	local chat = M.open(opts)
	chat:add_buf_message({
		role = config.constants.USER_ROLE,
		content = "Here is some code from "
			.. context.filename
			.. ":\n\n```"
			.. context.filetype
			.. "\n"
			.. content
			.. "\n```\n",
	})
end

return M
