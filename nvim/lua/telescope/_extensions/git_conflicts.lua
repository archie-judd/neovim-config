local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local telescope = require("telescope")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")

local M = {}

local function get_git_conflicts()
	local cmd = {
		"git",
		"grep",
		"--line-number",
		"--untracked",
		"-e",
		"'^<<<<<<< '",
		"--",
		".",
	}

	local results = {}
	local handle = io.popen(table.concat(cmd, " ") .. " 2>/dev/null")

	if not handle then
		return results
	end

	for line in handle:lines() do
		-- Parse git grep output: filename:line_number:content
		local filename, line_num, content = line:match("([^:]+):(%d+):(.*)")
		if filename and line_num and content then
			table.insert(results, {
				filename = filename,
				lnum = tonumber(line_num),
				col = 1,
				text = content:gsub("^%s*", ""), -- trim leading whitespace
				display = string.format("%s:%s: %s", filename, line_num, content:gsub("^%s*", "")),
			})
		end
	end

	handle:close()
	return results
end

-- Entry makethat works with builtin grep previewer
local function make_entry(entry)
	return {
		value = entry,
		display = entry.display,
		ordinal = entry.filename .. " " .. entry.text,
		filename = entry.filename,
		lnum = entry.lnum,
		col = entry.col,
		path = entry.filename,
	}
end

local function git_conflicts()
	local conflicts = get_git_conflicts()

	if #conflicts == 0 then
		vim.notify("No git conflicts found", vim.log.levels.INFO, {
			title = "Git Conflicts",
		})
		return
	end

	pickers
		.new({}, {
			prompt_title = "Git Conflicts",
			finder = finders.new_table({
				results = conflicts,
				entry_maker = make_entry,
			}),
			sorter = conf.generic_sorter({}),
			-- Use builtin grep previewer - much simpler!
			previewer = conf.grep_previewer({}),
			attach_mappings = function(prompt_bufnr, _)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						vim.cmd("edit " .. selection.filename)
						vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col - 1 })
					end
				end)
				return true
			end,
		})
		:find()
end

-- Setup function
return telescope.register_extension({
	setup = function(ext_config, config) end,
	exports = {
		git_conflicts = git_conflicts,
	},
})
