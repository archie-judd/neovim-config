local conf = require("telescope.config")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.pickers")
local telescope = require("telescope")

-- Custom Git Changes Picker
local function git_changed_files()
	local cmd = {
		"bash",
		"-c",
		"git diff --name-only && git diff --cached --name-only && git ls-files --others --exclude-standard",
	}

	pickers
		.new({}, {
			prompt_title = "Git Changed Files",
			finder = finders.new_oneshot_job(cmd, { entry_maker = make_entry.gen_from_file({}) }),
			previewer = conf.values.grep_previewer({}),
			sorter = conf.values.generic_sorter({}),
			layout_config = {
				width = 0.75,
				height = 0.75,
				scroll_speed = 4,
			},
		})
		:find()
end

return telescope.register_extension({
	setup = function(ext_config, config) end,
	exports = {
		git_changed_files = git_changed_files,
	},
})
