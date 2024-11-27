local mappings = require("config.mappings")
local usercommands = require("config.usercommands")
local config = function()
	usercommands.github_link()
	mappings.github_link()
end

return config()
