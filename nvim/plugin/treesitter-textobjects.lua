local config = function()
	local nvim_treesitter_configs = require("nvim-treesitter.configs")

	nvim_treesitter_configs.setup({
		textobjects = {
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					["al"] = { query = "@loop.outer", desc = "Treesitter: select loop outer" },
					["il"] = { query = "@loop.inner", desc = "Treesitter: select loop inner" },
					["ic"] = { query = "@conditional.inner", desc = "Treesitter: select conditional inner" },
					["ac"] = { query = "@conditional.outer", desc = "Treesitter: select conditional outer" },
					["af"] = { query = "@function.outer", desc = "Treesitter: select function outer" },
					["if"] = { query = "@function.inner", desc = "Treesitter: select function inner" },
					["aC"] = { query = "@class.outer", desc = "Treesitter: select class outer" },
					["iC"] = { query = "@class.inner", desc = "Treesitter: select class inner" },
					["as"] = {
						query = "@scope",
						query_group = "locals",
						desc = "Treesitter: select locals in scope",
					},
				},
			},
			swap = {
				enable = true,
				swap_next = {
					["<leader>a"] = {
						query = "@parameter.inner",
						desc = "Treesitter: swap current parameter with next",
					},
				},
				swap_previous = {
					["<leader>A"] = {
						query = "@parameter.inner",
						desc = "Treesitter: swap current parameter with previous",
					},
				},
			},
		},
	})
end

config()
