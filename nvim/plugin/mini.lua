local ai = require("mini.ai")
local diff = require("mini.diff")
local surround = require("mini.surround")

local config = function()
	ai.setup({ n_lines = 500 })
	surround.setup()
	diff.setup({
		view = { style = "sign" },
		-- only use for codecompanion
		source = diff.gen_source.none(),
	})
end

config()
