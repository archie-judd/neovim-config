local config = function()
	local catppuccin = require("catppuccin")
	catppuccin.setup({
		flavour = "mocha",
		custom_highlights = function(colors)
			return {
				DiffText = { bg = "#8b6547" },
				DiffChange = { bg = "#605955" },
			}
		end,
		float = {
			transparent = true,
			solid = false,
		},
		default_integrations = false,
		integrations = {
			telescope = { enabled = true },
		},
	})
end

config()
