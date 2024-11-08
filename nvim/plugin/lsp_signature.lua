local lsp_signature = require("lsp_signature")

local config = function()
	lsp_signature.setup({ hint_enable = false, toggle_key = "<C-s>" })
end

config()
