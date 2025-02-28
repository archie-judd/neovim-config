local conform = require("conform")

local function is_black_and_isort_installed()
	local command = "which black > /dev/null 2>&1 && which isort > /dev/null 2>&1"
	return os.execute(command) == 0
end

local function get_python_formatters()
	if is_black_and_isort_installed() then
		return { "isort", "black" }
	else
		return { "ruff" }
	end
end

local config = function()
	conform.setup({
		formatters_by_ft = {
			lua = { "stylua" },
			python = get_python_formatters(),
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
