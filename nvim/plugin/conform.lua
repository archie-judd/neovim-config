local conform = require("conform")

local config = function()
	conform.setup({
		formatters_by_ft = {
			lua = { "stylua" },
			python = function(bufnr)
				if conform.get_formatter_info("ruff_format", bufnr).available then
					return { "ruff_format" }
				else
					return { "isort", "black" }
				end
			end,
			javascript = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			json = function(bufnr)
				if conform.get_formatter_info("prettier", bufnr).available then
					return { "prettier" }
				else
					return { "jq" }
				end
			end,
			yaml = { "prettier" },
			markdown = { "prettier" },
			nix = { "nixfmt" },
			haskell = { "ormolu" },
		},
		format_on_save = {
			timeout_ms = 5000,
			lsp_fallback = true,
		},
		formatters = {
			black = {
				prepend_args = { "--preview" },
			},
		},
	})
end

config()
