local M = {}

---@return table
function M.get_float_window_opts()
	local layout = require("oil.layout")
	local total_width = vim.o.columns
	local total_height = layout.get_editor_height()
	local width = math.floor(vim.o.columns * 0.7)
	local height = math.floor(vim.o.lines * 0.7)
	local row = math.floor((total_height - height) / 2)
	local col = math.floor((total_width - width) / 2) - 1 -- adjust for border width
	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = "rounded",
		zindex = 45,
	}
	return win_opts
end

return M
