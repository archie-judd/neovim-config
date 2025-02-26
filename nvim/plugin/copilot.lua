local copilot = require("copilot")

local config = function()
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
end

config()
