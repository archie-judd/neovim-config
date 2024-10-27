local M = {}

function M.open_panel()
	local panel = require("copilot.panel")

	local number_of_columns = vim.api.nvim_win_get_width(0)
	local number_of_rows = vim.api.nvim_win_get_height(0)
	local desired_height = 20
	local desired_width = tonumber(vim.wo.colorcolumn)
	if desired_width == nil then
		desired_width = 80
	end

	-- If there is enough room to view two full lines of code side-by-side, open the panel vertically
	if number_of_columns >= desired_width * 2 then
		local panel_layout = {
			position = "right", -- | top | left | right
			ratio = math.min(0.5, desired_width / number_of_columns),
		}
		panel.open(panel_layout)
	-- Otherwise horizontally
	else
		local panel_layout = {
			position = "bottom",
			ratio = math.min(0.5, desired_height / number_of_rows),
		}
		panel.open(panel_layout)
	end
end

return M
