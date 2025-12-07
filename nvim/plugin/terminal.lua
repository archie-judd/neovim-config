local config = function()
	local autocommands = require("config.autocommands")
	local mappings = require("config.mappings")
	
	mappings.terminal()
	autocommands.terminal()
end

return config()
