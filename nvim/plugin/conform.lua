local conform = require("conform")

local config = function()
	conform.setup({
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "isort", "black" },
			javascript = { "prettierd" },
			typescript = { "prettierd" },
			typescriptreact = { "prettierd" },
			json = { "prettierd" },
			yaml = { "prettierd" },
			markdown = { "prettierd" },

			nix = { "nixfmt" },
			haskell = { "ormolu" },
		},
		format_on_save = {
			timeout_ms = 5000,
			lsp_fallback = true,
		},
	})
end

config()
