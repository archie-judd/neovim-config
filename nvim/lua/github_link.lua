local M = {}

---@return boolean
local function is_in_git_repo()
	local result = vim.system({ "git", "rev-parse", "--is-inside-work-tree" }, { text = true }):wait()
	if result.code ~= 0 then
		vim.notify(result.stderr, vim.log.levels.WARN)
		return false
	else
		return result.stdout:gsub("%s+", "") == "true"
	end
end

---@param file_path string
---@return boolean
local function is_file_tracked(file_path)
	local result = vim.system({ "git", "rev-parse", string.format("HEAD:%s", file_path) }):wait()
	if result.code ~= 0 then
		vim.notify(result.stderr, vim.log.levels.WARN)
		return false
	else
		return result.stdout:gsub("%s+", ""):len() > 0
	end
end

---@param file_path string
---@param commit string
---@return boolean
local function is_file_in_remote(file_path, commit)
	local result = vim.system({ "git", "cat-file", "-e", string.format("%s:%s", commit, file_path) }, { text = true })
		:wait()
	if result.code ~= 0 then
		vim.notify(result.stderr, vim.log.levels.WARN)
		return false
	else
		return true
	end
end

---@return string | nil
local function get_git_filepath_for_current_file()
	local result = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait()
	if result.code ~= 0 then
		vim.notify(result.stderr, vim.log.levels.ERROR)
		return nil
	else
		local git_root = result.stdout:gsub("\n$", "")
		local escaped_git_root = git_root:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
		local absolute_path = vim.fn.expand("%:p")
		local file_path = absolute_path:gsub("^" .. escaped_git_root .. "/", "")
		return file_path
	end
end

---@return string | nil
local function get_current_commit()
	local result = vim.system({ "git", "rev-parse", "HEAD" }, { text = true }):wait()
	if result.code ~= 0 then
		vim.notify(result.stderr, vim.log.levels.ERROR)
		return nil
	else
		local remotes = vim.split(result.stdout, "\n", { trimempty = true })
		return remotes[1] or nil
	end
end

---@param rev string
---@return string | nil
local function get_commit_for_rev(rev)
	local result = vim.system({ "git", "rev-parse", rev }, { text = true }):wait()
	if result.code ~= 0 then
		vim.notify(result.stderr, vim.log.levels.ERROR)
		return nil
	else
		return vim.split(result.stdout, "\n", { trimempty = true })[1] or nil
	end
end

---@param commit string
---@return string | nil
local get_remote_for_commit = function(commit)
	local result = vim.system({ "git", "branch", "-r", "--contains", commit }, { text = true }):wait()
	if result.code ~= 0 then
		vim.notify(result.stderr, vim.log.levels.ERROR)
		return nil
	else
		local branches = vim.split(result.stdout, "/", { trimempty = true })[1]:gsub("%s+", "") or nil
		return branches
	end
end

---@param remote string
---@return string | nil
local get_github_remote_url = function(remote)
	local result = vim.system({ "git", "config", "--get", string.format("remote.%s.url", remote) }, { text = true })
		:wait()
	if result.code ~= 0 then
		vim.notify(result.stderr, vim.log.levels.ERROR)
		return nil
	else
		local repo_url =
			result.stdout:gsub("\n$", ""):gsub("%.git$", ""):gsub("git%@", "https://"):gsub("com%:", "com/")
		return repo_url
	end
end

---@class Lines
---@field start number
---@field ['end'] number

---@param remote_url string
---@param commit string
---@param file_path string
---@param lines Lines | nil
---@return string
local make_github_link = function(remote_url, commit, file_path, lines)
	---@type string
	local url = string.format("%s/blob/%s/%s", remote_url, commit, file_path)

	if lines ~= nil then
		local lines_str = "L" .. lines.start
		if lines.start == lines["end"] then
			url = string.format("%s#%s", url, lines_str)
		elseif lines.start ~= lines["end"] then
			lines_str = lines_str .. "-L" .. lines["end"]
			url = string.format("%s#%s", url, lines_str)
		end
	end

	return url
end

---@param opts table | nil
function M.github_link(opts)
	opts = opts or { rev = nil, remote = nil, range = nil }

	if not is_in_git_repo() then
		vim.notify("Not in a git repository", vim.log.levels.WARN)
		return
	end

	---@type string | nil
	local commit
	if opts.rev ~= nil then
		commit = get_commit_for_rev(opts.rev)
	else
		commit = get_current_commit()
	end
	if commit == nil then
		vim.notify("Could not determine commit", vim.log.levels.ERROR)
		return
	end

	local remote = opts.remote
	if remote == nil then
		remote = get_remote_for_commit(commit)
		if remote == nil then
			vim.notify("Could not determine remote  for commit: " .. commit, vim.log.levels.ERROR)
			return
		end
	end

	local repo_url = get_github_remote_url(remote)
	if repo_url == nil then
		vim.notify("Could not determine remote URL for remote: " .. remote, vim.log.levels.ERROR)
		return
	end

	local file_path = get_git_filepath_for_current_file()
	if file_path == nil then
		vim.notify("Could not determine file path in git repository", vim.log.levels.ERROR)
		return
	end

	if not is_file_tracked(file_path) then
		vim.notify("File is not tracked", vim.log.levels.WARN)
		return
	end
	if not is_file_in_remote(file_path, commit) then
		vim.notify("File is not in remote", vim.log.levels.WARN)
		return
	end

	local url = string.format("%s/blob/%s/%s", repo_url, commit, file_path)

	local mode = vim.api.nvim_get_mode().mode

	---@type Lines | nil
	local lines
	if mode:lower() == "v" or opts.range == true then
		local start_line = vim.fn.line("'<")
		local end_line = vim.fn.line("'>")
		lines = { start = start_line, ["end"] = end_line }
	end

	url = make_github_link(repo_url, commit, file_path, lines)

	vim.fn.setreg("+", url)
	vim.notify("Copied Github URL: " .. url, vim.log.levels.INFO)
end

return M
