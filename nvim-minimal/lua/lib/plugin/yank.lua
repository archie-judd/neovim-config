local M = {}

local core = require("lib.core")

--- Build the line range suffix for the current visual selection, collapsing a
--- single-line selection to ":<line>".
--- @param range boolean|nil
--- @return string
local function format_line_range_suffix(range)
	if not range then
		return ""
	end
	local lines = core.get_visual_line_range()
	if lines == nil then
		return ""
	end
	if lines.start == lines["end"] then
		return ":" .. lines.start
	end
	return ":" .. lines.start .. "-" .. lines["end"]
end

--- Yank the current file absolute path to the specified register.
--- Defaults to the system clipboard register if none is provided.
--- Appends the line range when invoked over a visual selection.
--- @param register string|nil
--- @param range boolean|nil
function M.yank_abs_filepath(register, range)
	if register == nil then
		register = "+"
	end
	local file_path = vim.fn.expand("%:p") .. format_line_range_suffix(range)
	vim.fn.setreg(register, file_path)
	vim.notify("Yanked '" .. file_path .. "' to register " .. register, vim.log.levels.INFO)
end

--- Yank the current file path relative to the current working directory to the specified register.
--- Defaults to the system clipboard register if none is provided.
--- Appends the line range when invoked over a visual selection.
--- @param register string|nil
--- @param range boolean|nil
function M.yank_rel_filepath(register, range)
	if register == nil then
		register = "+"
	end
	local file_path = vim.fn.expand("%:.") .. format_line_range_suffix(range)
	vim.fn.setreg(register, file_path)
	vim.notify("Yanked '" .. file_path .. "' to register " .. register, vim.log.levels.INFO)
end

--- Yank the current file name (without path) to the specified register.
--- Defaults to the system clipboard register if none is provided.
--- Appends the line range when invoked over a visual selection.
--- @param register string|nil
--- @param range boolean|nil
function M.yank_filename(register, range)
	if register == nil then
		register = "+"
	end
	local file_name = vim.fn.expand("%:t") .. format_line_range_suffix(range)
	vim.fn.setreg(register, file_name)
	vim.notify("Yanked '" .. file_name .. "' to register " .. register, vim.log.levels.INFO)
end

return M
