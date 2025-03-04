local codecompanion = require("codecompanion")
local utils = require("utils.core")

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
			else
				local winnr = utils.get_winnr_for_bufnr(chat.ui.bufnr)
				if winnr then
					vim.api.nvim_set_current_win(winnr)
				end
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

function M.close()
	local chat = codecompanion.last_chat()

	if chat ~= nil and chat.ui:is_visible() then
		local bufnr = chat.context.buffer
		diff.disable(bufnr)
		chat.ui:hide()
	end
end

return M
