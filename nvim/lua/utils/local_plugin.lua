local M = {}

---Add a local plugin to the runtimepath, prepending so that it takes precendence over any installed modules. This
---should be used for development purposes only, and must be run at the top of init.lua
---@param dir_path string
function M.load_local_plugin(dir_path)
	if vim.fn.isdirectory(dir_path) == 0 then
		vim.notify("Directory does not exist: " .. dir_path, vim.log.levels.ERROR)
		return
	end
	local dir_abs = vim.fn.fnamemodify(dir_path, ":p")
	vim.print(dir_abs)
	local parent = vim.fn.fnamemodify(dir_abs, ":h")
	vim.print(parent)
	vim.opt.runtimepath:prepend(parent)
end

return M
