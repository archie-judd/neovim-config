local autocommands = require("config.autocommands")
local mappings = require("config.mappings")

local config = function()
	mappings.float_term()
	autocommands.float_term()
end

return config()
