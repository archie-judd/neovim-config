local config = function()
	local ibl = require("ibl")
	
	ibl.setup({ indent = { char = "▏" }, scope = { enabled = false } })
end

config()
