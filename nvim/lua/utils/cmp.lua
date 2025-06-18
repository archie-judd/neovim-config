local cmp = require("blink.cmp")
local suggestion = require("copilot.suggestion")

local M = {}

function M.start()
	if not suggestion.is_visible() then
		suggestion.next()
	elseif not cmp.is_visible() then
		cmp.accept()
	end
end

function M.select_next()
	if cmp.is_visible() then
		cmp.select_next()
	elseif suggestion.is_visible() then
		suggestion.next()
	end
end

function M.select_prev()
	if cmp.is_visible() and cmp.get_selected_item() ~= nil then
		cmp.select_prev()
	elseif suggestion.is_visible() then
		suggestion.prev()
	end
end

function M.accept()
	if cmp.is_visible() and cmp.get_selected_item() ~= nil then
		cmp.accept()
	elseif suggestion.is_visible() then
		suggestion.accept()
	end
end

function M.close()
	if cmp.is_visible() then
		cmp.cancel()
	elseif suggestion.is_visible() then
		suggestion.dismiss()
	end
end

function M.scroll_documentation_up()
	if cmp.is_documentation_visible() then
		cmp.scroll_documentation_up(4)
	end
end

function M.scroll_documentation_down()
	if cmp.is_documentation_visible() then
		cmp.scroll_documentation_down(4)
	end
end

function M.toggle_documentation()
	if cmp.is_documentation_visible() then
		cmp.hide_documentation()
	else
		cmp.show_documentation()
	end
end

function M.toggle_signature()
	vim.print("Toggling signature help")
	vim.g.cmp_signature_help = not vim.g.cmp_signature_help
	if vim.g.cmp_signature_help then
		cmp.hide_signature()
	else
		cmp.show_signature()
	end
end

return M
