local codecompanion = require("codecompanion")
local diff = require("mini.diff")
local utils = require("utils.core")

local M = {}

function M.read_anthropic_api_key()
	local home = os.getenv("HOME") or "~"
	local path = home .. "/.config/anthropic_token"

	local file = io.open(path, "r")
	if not file then
		vim.notify("Error: Unable to open " .. path, vim.log.levels.ERROR)
		return nil
	end

	local api_key = file:read("*l")
	file:close()

	if not api_key or api_key == "" then
		return nil
	end
	return api_key
end

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
		diff.goto_hunk("first")
	end
end

return M
