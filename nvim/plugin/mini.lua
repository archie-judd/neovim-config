local config = function()
	local ai = require("mini.ai")
	
	ai.setup({ custom_textobjects = { b = false }, n_lines = 500 })
end

config()
