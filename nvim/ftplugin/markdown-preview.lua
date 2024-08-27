local config = function()
	local mappings = require("config.mappings")
	mappings.markdown_preview()
	--	vim.fn["mkdp#util#install"]()
end

config()
