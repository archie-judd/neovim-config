M = {}

function M.yank_filepath_to_system_register()
	local file_path = vim.fn.expand("%:p")
	vim.print(file_path)
	vim.fn.setreg("+", file_path)
end

function M.yank_filename_to_system_register()
	local file_name = vim.fn.expand("%:t")
	vim.print(file_name)
	vim.fn.setreg("+", file_name)
end

return M
