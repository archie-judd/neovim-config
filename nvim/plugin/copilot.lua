local config = function()
	local copilot = require("copilot")

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

local function load_on_event()
	local lazy_load_utils = require("utils.lazy_load")
	lazy_load_utils.load_plugin_on_event(config, "copilot", { "InsertEnter", "TextChanged", "TextChangedI" }, nil)
end

load_on_event()
