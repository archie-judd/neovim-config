local function config()
	local lsp_signature = require("lsp_signature")
	lsp_signature.setup({ hint_enable = false, toggle_key = "<C-s>" })
end

config()
