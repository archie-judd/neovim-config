local configs = require("nvim-treesitter.configs")

local config = function()
	configs.setup({
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},
		indent = { enable = true },
	})
end

config()
