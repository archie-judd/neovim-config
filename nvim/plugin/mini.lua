local ai = require("mini.ai")

local config = function()
	ai.setup({ custom_textobjects = { b = false }, n_lines = 500 })
end

config()
