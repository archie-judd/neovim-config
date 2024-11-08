local ai = require("mini.ai")
local surround = require("mini.surround")

local config = function()
	ai.setup({ n_lines = 500 })
	surround.setup()
end

config()
