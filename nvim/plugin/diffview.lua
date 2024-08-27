local config = function()
	local diffview = require("diffview")
	local mappings = require("config.mappings")
	local autocommands = require("config.autocommands")

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
			file_panel = {
				["-"] = false,
			},
		},
	})
	mappings.diffview()
	autocommands.diffview()
end

config()
