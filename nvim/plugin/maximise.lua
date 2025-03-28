local autocommands = require("config.autocommands")
local mappings = require("config.mappings")

local config = function()
	mappings.maximise()
	autocommands.maximise()
end

return config()
