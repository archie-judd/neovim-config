local avante = require("avante")
local avante_lib = require("avante_lib")

local config = function()
	avante_lib.load()
	avante.setup({
		windows = {
			ask = { floating = true },
		},
	})
end

-- config()
