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
			sh = { "shfmt" },
			nix = { "nixfmt" },
			haskell = { "ormolu" },
			sql = { "pg_format" },
		},
		format_on_save = {
			timeout_ms = 5000,
			lsp_fallback = true,
		},
		formatters = {
			black = {
				prepend_args = { "--preview" },
			},
			pg_format = {
				-- set types to upper case and stop it from separating tables of format #table_name to
				-- # table_name
				prepend_args = { "--type-case", 2, "--placeholder", [[#\w+]] },
			},
		},
	})
end

config()
