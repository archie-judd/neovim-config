local config = function()
	local usercommands = require("config.usercommands")

	usercommands.yank_filepath()
end

config()
