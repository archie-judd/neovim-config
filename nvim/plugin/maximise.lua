local config = function()
	local autocommands = require("config.autocommands")
	local mappings = require("config.mappings")
	
	mappings.maximise()
	autocommands.maximise()
end

return config()
