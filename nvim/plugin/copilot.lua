local config = function()
	local copilot = require("copilot")
	local mappings = require("config.mappings")
	local autocommands = require("config.autocommands")

	copilot.setup({
		suggestion = {
			enabled = true,
			auto_trigger = true,
			keymap = {
				accept = false,
				accept_word = false,
				accept_line = false,
				next = false,
				prev = false,
				dismiss = false,
			},
		},
		panel = {
			enabled = false,
			auto_refresh = true,
		},
	})
	autocommands.copilot()
	mappings.copilot_panel()
end

config()
