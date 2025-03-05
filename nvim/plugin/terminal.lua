local autocommands = require("config.autocommands")
local mappings = require("config.mappings")

local config = function()
	mappings.terminal()
	autocommands.terminal()
end

return config()
