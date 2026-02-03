M = {}

--- Yank the current file absolute path to the specified register.
--- Defaults to the system clipboard register if none is provided.
--- @param register string|nil
function M.yank_abs_filepath(register)
	if register == nil then
		register = "+"
	end
	local file_path = vim.fn.expand("%:p")
	vim.fn.setreg(register, file_path)
	vim.notify("Yanked '" .. file_path .. "' to register " .. register, vim.log.levels.INFO)
end

--- Yank the current file path relative to the current working directory to the specified register.
--- Defaults to the system clipboard register if none is provided.
--- @param register string|nil
function M.yank_rel_filepath(register)
	if register == nil then
		register = "+"
	end
	local file_path = vim.fn.expand("%:.")
	vim.fn.setreg(register, file_path)
	vim.notify("Yanked '" .. file_path .. "' to register " .. register, vim.log.levels.INFO)
end

--- Yank the current file name (without path) to the specified register.
--- Defaults to the system clipboard register if none is provided.
--- @param register string|nil
function M.yank_filename(register)
	if register == nil then
		register = "+"
	end
	local file_name = vim.fn.expand("%:t")
	vim.fn.setreg(register, file_name)
	vim.notify("Yanked '" .. file_name .. "' to register " .. register, vim.log.levels.INFO)
end

return M
