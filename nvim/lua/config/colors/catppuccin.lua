local catppuccin = require("catppuccin")

local config = function()
	catppuccin.setup({
		flavour = "mocha",
		custom_highlights = function(colors)
			return {
				DiffText = { bg = "#8b6547" },
				DiffChange = { bg = "#605955" },
			}
		end,
	})
end

config()
