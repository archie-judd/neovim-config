local config = function()
	local ibl = require("ibl")
	local hooks = require("ibl.hooks")
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
	-- don't show or highlight the first indent
	hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
	hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_tab_indent_level)
end

config()
