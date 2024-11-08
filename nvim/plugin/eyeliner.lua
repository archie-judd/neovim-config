local autocommands = require("config.autocommands")
local eyeliner = require("eyeliner")

local config = function()
	eyeliner.setup({
		highlight_on_key = true,
		dim = true,
	})
	autocommands.eyeliner()
end

config()
