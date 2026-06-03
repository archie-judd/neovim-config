local config = function()
	local autocommands = require("config.autocommands")
	local conform = require("conform")

	conform.setup({
		formatters_by_ft = {
			lua = { "stylua" },
			python = function(bufnr)
				if conform.get_formatter_info("ruff_format", bufnr).available then
					return { "ruff_organize_imports", "ruff_format" }
				else
					return { "isort", "black" }
				end
			end,
			javascript = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			css = { "prettier" },
			html = { "prettier" },
			json = { "prettier", "jq", stop_after_first = true },
			jsonl = { "jq" },
			yaml = { "prettier" },
			markdown = { "prettier", "mdformat", stop_after_first = true },
			nix = { "nixfmt" },
			haskell = { "ormolu" },
		},
		format_on_save = {
			timeout_ms = 5000,
			lsp_fallback = "fallback",
		},
		formatters = {
			black = {
				prepend_args = { "--preview" },
			},
			jq = {
				args = { "--indent", "2" },
			},
		},
	})
	autocommands.conform()
end

config()
