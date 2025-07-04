local catppuccin = require("catppuccin")

local config = function()
	local flavour = "mocha" -- Default flavour
	catppuccin.setup({ flavour = flavour })
	if flavour == "mocha" then
		-- Make inline diffs orange
		vim.api.nvim_set_hl(0, "DiffText", { bg = "#604b49", fg = "#fab387" })
	end
end

config()
