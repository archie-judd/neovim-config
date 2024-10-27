local M = {}

function M.open_diffview()
	local core_utils = require("utils.core")
	local diffview = require("diffview")

	local diffview_bufnr = core_utils.get_buffer_by_pattern("**DiffviewFilePanel$")

	if diffview_bufnr == nil then
		diffview.open()
	else
		local diffview_tabnr = core_utils.get_tabpage_for_buffer(diffview_bufnr)
		if diffview_tabnr == nil then
			diffview.close()
			diffview.open()
		else
			vim.api.nvim_set_current_tabpage(diffview_tabnr)
		end
	end
end

return M
