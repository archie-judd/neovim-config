local config = function()
	local eyeliner = require("eyeliner")
	local autocommands = require("config.autocommands")

	eyeliner.setup({
		highlight_on_key = true,
		dim = true,
	})
	autocommands.eyeliner()
end

config()
