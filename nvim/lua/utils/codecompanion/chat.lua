local codecompanion = require("codecompanion")
local config = require("codecompanion.config")
local context_utils = require("codecompanion.utils.context")

local M = {}

function M.submit()
	local chat = codecompanion.last_chat()
	if chat ~= nil then
		chat:submit()
		vim.cmd("stopinsert")
	end
end

---@param opts table
function M.open(opts)
	opts = opts or {}
	local chat = codecompanion.last_chat()

	if not chat then
		codecompanion.chat()
	else
		if chat.ui:is_visible() then
			if opts.new then
				codecompanion.close_last_chat()
				codecompanion.chat()
			end
		else
			if opts.new then
				codecompanion.chat()
			else
				chat.ui:open()
			end
		end
	end
end

---@param opts table
function M.add(opts)
	opts = opts or {}
	local chat = codecompanion.last_chat()

	if not chat then
		local context = context_utils.get(vim.api.nvim_get_current_buf(), nil)
		local content = table.concat(context.lines, "\n")
		vim.cmd("normal! <Esc>")
		chat = codecompanion.chat()
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
	else
		codecompanion.add()
	end
end

function M.close()
	local chat = codecompanion.last_chat()

	if chat ~= nil and chat.ui:is_visible() then
		chat.ui:hide()
	end
end

return M
