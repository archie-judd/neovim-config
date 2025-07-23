local core_utils = require("utils.core")
local diffview = require("diffview")

local M = {}

function M.open_diffview()
	local diffview_bufnr = core_utils.get_bufnr_by_pattern("**DiffviewFilePanel$")

	if diffview_bufnr == nil then
		diffview.open({})
	else
		local diffview_tabnr = core_utils.get_tabnr_for_bufnr(diffview_bufnr)
		if diffview_tabnr == nil then
			diffview.close()
			diffview.open({})
		else
			vim.api.nvim_set_current_tabpage(diffview_tabnr)
		end
	end
end

function M.open_diffview_file_history()
	local filepath = vim.api.nvim_buf_get_name(0)
	local file_history_bufnr = core_utils.get_bufnr_by_pattern("**DiffviewFileHistoryPanel$")

	if file_history_bufnr == nil then
		diffview.file_history(nil, { filepath })
	else
		local diffview_tabnr = core_utils.get_tabnr_for_bufnr(file_history_bufnr)
		if diffview_tabnr == nil then
			diffview.close()
			diffview.file_history(nil, { filepath })
		else
			vim.api.nvim_set_current_tabpage(diffview_tabnr)
		end
	end
end
return M
