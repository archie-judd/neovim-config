M = {}

function M.yank_filepath_to_unnamed_register()
	local file_path = vim.fn.expand("%:p")
	vim.fn.setreg("", file_path)
end

function M.yank_filename_to_unnamed_register()
	local file_name = vim.fn.expand("%:t")
	vim.fn.setreg("", file_name)
end

function M.yank_filepath_to_system_register()
	local file_path = vim.fn.expand("%:p")
	vim.fn.setreg("+", file_path)
end

function M.yank_filename_to_system_register()
	local file_name = vim.fn.expand("%:t")
	vim.fn.setreg("+", file_name)
end

return M
