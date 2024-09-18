local M = {}

---@param file_path string
---@return boolean
local function is_typescript_file(file_path)
	return string.match(file_path, "%.ts$") or string.match(file_path, "%.tsx$")
end

function M.tsserver_organize_imports()
	local params = {
		command = "_typescript.organizeImports",
		arguments = { vim.api.nvim_buf_get_name(0) },
		title = "",
	}
	vim.lsp.buf.execute_command(params)
end

function M.tsserver_organize_all_changed_imports()
	-- Get the list of changed files from git (staged, modified, and untracked)
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	local git_files = vim.fn.systemlist("git ls-files --modified --others --exclude-standard")

	-- Iterate over the list of git files and apply the placeholder function
	for _, git_path in ipairs(git_files) do
		-- Skip empty lines (in case there are any)
		if is_typescript_file(git_path) then
			local absolute_path = git_root .. "/" .. git_path
			local params = {
				command = "_typescript.organizeImports",
				arguments = { absolute_path },
				title = "",
			}
			vim.lsp.buf.execute_command(params)
		end
	end
end

return M
