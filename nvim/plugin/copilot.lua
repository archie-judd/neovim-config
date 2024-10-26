local config = function()
	local copilot = require("copilot")
	local mappings = require("config.mappings")
	local autocommands = require("config.autocommands")

	copilot.setup({
		suggestion = {
			enabled = false,
		},
		panel = {
			enabled = true,
			layout = {
				position = "right", -- | top | left | right
				ratio = 0.3,
			},
		},
	})
	autocommands.copilot()
	mappings.copilot()
end

config()
