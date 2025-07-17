local catppuccin = require("catppuccin")

local config = function()
	catppuccin.setup({
		flavour = "mocha",
		custom_highlights = function(colors)
			return {
				DiffText = { bg = "#5a4b34" },
				DiffChange = { bg = "" },
			}
		end,
	})
end

config()
