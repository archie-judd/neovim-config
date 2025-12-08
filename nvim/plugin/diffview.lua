local config = function()
	local autocommands = require("config.autocommands")
	local diffview = require("diffview")
	local mappings = require("config.mappings")

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

local function load_on_keymap()
	local lazy_load_util = require("utils.lazy_load")
	lazy_load_util.load_plugin_on_keymap(config, "diffview", { "n" }, { "<Leader>gs", "<Leader>gh" })
end

load_on_keymap()
