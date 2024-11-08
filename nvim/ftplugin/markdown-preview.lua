local mappings = require("config.mappings")

local config = function()
	mappings.markdown_preview()
	--	vim.fn["mkdp#util#install"]()
end

config()
