local nvim_treesitter_configs = require("nvim-treesitter.configs")

local config = function()
	vim.treesitter.query.set(
		"markdown",
		"textobjects",
		[[;extends
    (fenced_code_block) @fenced_code_block.outer

    (fenced_code_block
       (code_fence_content) @fenced_code_block.inner)
    ]]
	)
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
					["ab"] = { query = "@fenced_code_block.outer", desc = "Treesitter: select block outer" },
					["ib"] = { query = "@fenced_code_block.inner", desc = "Treesitter: select block outer" },
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
