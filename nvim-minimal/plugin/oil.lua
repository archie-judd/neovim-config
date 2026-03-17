local config = function()
	local actions = require("oil.actions")
	local autocommands = require("config.autocommands")
	local mappings = require("config.mappings")
	local oil = require("oil")
	local oil_utils = require("lib.plugin.oil")

	oil.setup({
		keymaps = { ["<C-p>"] = false, ["<C-y>"] = actions.select },
		float = {
			override = oil_utils.get_float_window_opts,
			preview_split = "right",
		},
		win_options = {
			signcolumn = "yes",
		},
	})

	mappings.oil()
	autocommands.oil()
end

config()
