local change_chat_adapter = require("codecompanion.interactions.chat.keymaps.change_adapter")
local codecompanion = require("codecompanion")
local config = require("codecompanion.config")
local context_utils = require("codecompanion.utils.context")

local M = {}

---@param opts table
---@return CodeCompanion.Chat | nil
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
	if chat == nil then
		vim.notify("Failed to open chat.", vim.log.levels.ERROR)
		return nil
	end
	return chat
end

---@param opts table
function M.add_selection(opts)
	opts = opts or {}
	local context = context_utils.get(vim.api.nvim_get_current_buf(), nil)
	local content = table.concat(context.lines, "\n")
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
	local chat = M.open(opts)
	if chat == nil then
		vim.notify("No active chat found to add selection.", vim.log.levels.WARN)
		return
	end
	chat:add_buf_message({
		role = config.constants.USER_ROLE,
		content = "```" .. context.filetype .. "\n" .. content .. "\n```\n\n",
	})
end

function M.send_prompt()
	local chat = codecompanion.last_chat()
	if chat ~= nil then
		chat:submit()
		vim.cmd("stopinsert")
	else
		vim.notify("No active chat found to send prompt.", vim.log.levels.WARN)
	end
end

function M.close_chat()
	local chat = codecompanion.last_chat()
	if chat ~= nil and chat.ui:is_visible() then
		chat.ui:hide()
	else
		vim.notify("No active chat found to close.", vim.log.levels.WARN)
	end
end

function M.change_chat_adapter()
	local chat = codecompanion.last_chat()
	if not chat then
		chat = codecompanion.chat()
	end
	if chat == nil then
		vim.notify("No active chat found to change adapter.", vim.log.levels.WARN)
		return
	end
	local ignore_system_prompt_original = chat.opts.ignore_system_prompt
	chat.opts.ignore_system_prompt = true
	change_chat_adapter.callback(chat)
	chat.opts.ignore_system_prompt = ignore_system_prompt_original
	config.interactions.chat.adapter = chat.adapter
end

return M
