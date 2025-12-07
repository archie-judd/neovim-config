local config = function()
	local autocommands = require("config.autocommands")
	local eyeliner = require("eyeliner")
	
	eyeliner.setup({
		highlight_on_key = true,
		dim = true,
	})
	autocommands.eyeliner()
end

config()
