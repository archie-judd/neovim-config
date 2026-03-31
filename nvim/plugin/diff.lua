local config = function()
	local usercommands = require("config.usercommands")
	usercommands.branch_diff()
end

config()
