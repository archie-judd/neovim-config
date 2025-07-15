local catppuccin = require("catppuccin")

local config = function()
	catppuccin.setup({
		flavour = "mocha",
		custom_highlights = function(colors)
			return {
				DiffText = { fg = colors.peach, bg = colors.surface0 },
			}
		end,
	})
end

config()
