local mappings = require("config.mappings")
local textobjects = require("nvim-treesitter-textobjects")

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
	textobjects.setup({
		select = {
			enable = true,
			lookahead = true,
		},
	})
	mappings.textobjects()
end

config()
