local config = function()
	local gitsigns = require("gitsigns")
	local mappings = require("config.mappings")
	gitsigns.setup({
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
		on_attach = function(buffer)
			mappings.gitsigns(buffer)
		end,
		preview_config = { border = "rounded", focusable = false },
	})
end

config()
