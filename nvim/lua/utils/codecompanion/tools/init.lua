local M = {}

local filepath = debug.getinfo(1, "S").source:sub(2)
local abs_path = vim.fn.fnamemodify(filepath, ":p")
M.module_dir = abs_path:match("(.*/)")

return M
