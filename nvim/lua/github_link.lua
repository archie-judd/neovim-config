local M = {}

---@param file_path string
---@param branch string
---@return boolean
local function is_file_in_remote_branch(file_path, branch)
	local file_hash_cmd = string.format("git rev-parse HEAD:%s 2>/dev/null", file_path)
	local file_hash = vim.fn.system(file_hash_cmd):gsub("%s+", "")

	if file_hash == "" then
		vim.notify("File is not tracked in the current branch.", vim.log.levels.WARN)
		return false
	end

	-- Check if the file exists in the specified branch on the remote
	local remote_check_cmd = string.format("git ls-tree -r origin/%s --name-only | grep -Fx %s", branch, file_path)
	local remote_check = vim.fn.system(remote_check_cmd)

	return remote_check ~= ""
end

---@param branch string
---@return boolean
local function is_branch_in_remote(branch)
	local remote_branches = vim.fn.system("git branch -r"):gsub("%s+", "")

	if remote_branches:find(branch) then
		return true
	else
		return false
	end
end

---@param opts table | nil
function M.github_link(opts)
	opts = opts or { branch = nil, range = nil }

	---@type string
	local branch = opts.branch
	if opts.branch == nil then
		branch = vim.fn.system("git rev-parse --abbrev-ref HEAD"):gsub("%s+", "")
	end
	if not is_branch_in_remote(branch) then
		vim.notify("Branch is not in remote", vim.log.levels.WARN)
		return
	end

	local repo = vim.fn
		.system("git config --get remote.origin.url")
		:gsub("\n$", "")
		:gsub("%.git$", "")
		:gsub("git%@", "https://")
		:gsub("com%:", "com/")

	local encoded_branch = vim.fn.shellescape(branch):gsub("^'(.*)'$", "%1")

	local git_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n$", "")
	local escaped_git_root = git_root:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
	local absolute_path = vim.fn.expand("%:p")
	local file_path = absolute_path:gsub("^" .. escaped_git_root .. "/", "")
	if not is_file_in_remote_branch(file_path, branch) then
		vim.notify("File is not in remote branch", vim.log.levels.WARN)
		return
	end

	local url = string.format("%s/blob/%s/%s", repo, encoded_branch, file_path)

	local mode = vim.api.nvim_get_mode().mode

	local lines
	if mode:lower() == "v" or opts.range == true then
		local start_line = vim.fn.line("'<")
		local end_line = vim.fn.line("'>")
		lines = "L" .. start_line
		if start_line ~= end_line then
			lines = lines .. "-L" .. end_line
		end
		url = string.format("%s#%s", url, lines)
	end

	vim.fn.setreg("+", url)
	vim.notify("Copied Github URL: " .. url, vim.log.levels.INFO)
end

return M
