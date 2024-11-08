local cmp = require("cmp")
local suggestion = require("copilot.suggestion")

local M = {}

function M.start()
	if not suggestion.is_visible() then
		suggestion.next()
	elseif not cmp.visible() then
		cmp.complete()
	end
end

function M.select_next()
	if cmp.visible() then
		cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
	elseif suggestion.is_visible() then
		suggestion.next()
	end
end

function M.select_prev()
	if cmp.visible() and cmp.get_selected_entry() ~= nil then
		cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
	elseif suggestion.is_visible() then
		suggestion.prev()
	end
end

function M.accept()
	if cmp.visible() and cmp.get_selected_entry() ~= nil then
		cmp.confirm({ select = true })
	elseif suggestion.is_visible() then
		suggestion.accept()
	end
end

function M.close()
	if cmp.visible() then
		cmp.abort()
	elseif suggestion.is_visible() then
		suggestion.dismiss()
	end
end

return M
