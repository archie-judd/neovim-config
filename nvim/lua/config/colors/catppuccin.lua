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
			transparent = true, -- Make the float background the same as the normal background
			solid = false,
		},
		default_integrations = false,
		integrations = {
			blink_cmp = {
				style = "bordered",
			},
			gitsigns = { enabled = true, transparent = false },
			telescope = { enabled = true },
			dap = true,
			diffview = true,
		},
	})
end

config()
