local config = function()
	local autocommands = require("config.autocommands")
	local conform = require("conform")

	conform.setup({
		formatters = {
			black = {
				prepend_args = { "--preview" },
			},
			jq = {
				args = { "--indent", "2" },
			},
			shfmt = {
				prepend_args = { "-i", "2" },
			},
		},
		formatters_by_ft = {
			lua = { "stylua" },
			python = function(bufnr)
				if conform.get_formatter_info("ruff_format", bufnr).available then
					return { "ruff_organize_imports", "ruff_format" }
				else
					return { "isort", "black" }
				end
			end,
			javascript = { "oxfmt", "prettier", stop_after_first = true },
			typescript = { "oxfmt", "prettier", stop_after_first = true },
			typescriptreact = { "oxfmt", "prettier", stop_after_first = true },
			css = { "oxfmt", "prettier", stop_after_first = true },
			html = { "oxfmt", "prettier", stop_after_first = true },
			json = { "prettier", "jq", stop_after_first = true },
			jsonl = { "jq" },
			yaml = { "oxfmt", "prettier", stop_after_first = true },
			toml = { "oxfmt", "prettier", stop_after_first = true },
			markdown = { "oxfmt", "prettier", "mdformat", stop_after_first = true },
			nix = { "nixfmt" },
			haskell = { "ormolu" },
			bash = { "shfmt" },
			zsh = { "shfmt" },
			sh = { "shfmt" },
		},
		format_on_save = {
			timeout_ms = 5000,
			lsp_fallback = "fallback",
		},
	})
	autocommands.conform()
end

config()
