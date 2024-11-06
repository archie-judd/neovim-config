local config = function()
	local ibl = require("ibl")
	-- indent chars by thickness
	-- `▏`
	-- `▎`
	-- `▍`
	-- `▌`
	-- `▋`
	-- `▊`
	-- `▉`
	-- `█`
	ibl.setup({ indent = { char = "▏" }, scope = { show_start = false, show_end = false } })
end

config()
