local config = function()
	local ai = require("mini.ai")
	local surround = require("mini.surround")
	ai.setup({ n_lines = 500 })
	surround.setup()
end

config()
