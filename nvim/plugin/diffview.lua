local actions = require("diffview.actions")
local autocommands = require("config.autocommands")
local diffview = require("diffview")
local mappings = require("config.mappings")

local config = function()
	diffview.setup({
		file_panel = {
			listing_style = "list",
			win_config = { -- See ':h diffview-config-win_config'
				position = "left",
				width = 45,
				win_opts = {},
			},
		},
		keymaps = {
			view = {
				{
					"n",
					"[c",
					actions.prev_conflict,
					{ desc = "In the merge-tool: jump to the previous conflict" },
				},
				{
					"n",
					"]c",
					actions.next_conflict,
					{ desc = "In the merge-tool: jump to the next conflict" },
				},
			},
			file_panel = {
				["-"] = false,
			},
		},
	})
	mappings.diffview()
	autocommands.diffview()
end

config()
