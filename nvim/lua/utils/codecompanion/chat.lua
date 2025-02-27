local codecompanion = require("codecompanion")
local diff = require("mini.diff")
local utils = require("utils.core")

local M = {}

function M.submit()
	local chat = codecompanion.last_chat()
	if chat ~= nil then
		chat:submit()
		vim.cmd("stopinsert")
	end
end

function M.open_chat()
	local chat = codecompanion.last_chat()

	if not chat then
		codecompanion.chat()
	else
		if chat.ui:is_visible() then
			local winnr = utils.get_winnr_for_bufnr(chat.ui.bufnr)
			if winnr then
				vim.api.nvim_set_current_win(winnr)
			end
		else
			codecompanion.chat()
		end
	end
end

function M.close_chat()
	local chat = codecompanion.last_chat()

	if chat ~= nil and chat.ui:is_visible() then
		local bufnr = chat.context.buffer
		diff.disable(bufnr)
		chat.ui:hide()
	end
end

function M.jump_to_context_buffer()
	local chat = codecompanion.last_chat()
	if not chat or not chat.context or not chat.context.bufnr then
		vim.notify("No active CodeCompanion context found", vim.log.levels.WARN)
		return
	end

	local winnr = utils.get_winnr_for_bufnr(chat.context.bufnr)
	if not winnr then
		vim.notify("Buffer window not found", vim.log.levels.WARN)
		return
	end

	vim.api.nvim_set_current_win(winnr)

	local diff_info = diff.get_buf_data()
	if diff_info and #diff_info.hunks > 0 then
		-- go to the first hunk
		diff.goto_hunk("first")
		-- center the window
		vim.api.nvim_command("normal! zz")
	end
end

return M
