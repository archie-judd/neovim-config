local config = function()
	local copilot = require("copilot")
	local mappings = require("config.mappings")
	local autocommands = require("config.autocommands")

	copilot.setup({
		suggestion = {
			enabled = false,
		},
		panel = { enabled = false },
	})
	autocommands.copilot()
	mappings.copilot()
end

config()
