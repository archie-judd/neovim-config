local config = function()
	local mappings = require("config.mappings")
	local usercommands = require("config.usercommands")

	usercommands.github_link()
	mappings.github_link()
end

config()
