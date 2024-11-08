local cmp = require("cmp")
local cmp_dap = require("cmp_dap")
local mappings = require("config.mappings")
local usercommands = require("config.usercommands")

local config = function()
	cmp.setup({
		enabled = function()
			local enabled = (
				(vim.api.nvim_get_option_value("buftype", { buf = 0 }) ~= "prompt" or cmp_dap.is_dap_buffer())
				and vim.g.cmp_enabled ~= false
			)
			return enabled
		end,
		view = {
			docs = {
				auto_open = false,
			},
		},
		completion = { completeopt = "menuone,noinsert,noselect" },
		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "nvim_lsp_signature_help" },
		}),
		sorting = {
			comparators = {
				cmp.config.compare.offset,
				cmp.config.compare.exact,
				cmp.config.compare.score,
				cmp.config.compare.recently_used,
				cmp.config.compare.locality,
				cmp.config.compare.kind,
				cmp.config.compare.sort_text,
				cmp.config.compare.length,
				cmp.config.compare.order,
			},
		},
	})

	cmp.setup.cmdline({ "/", "?" }, {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{ name = "buffer" },
		},
	})

	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({
			{ name = "path" },
		}, {
			{ name = "cmdline" },
		}),
		matching = { disallow_symbol_nonprefix_matching = false },
	})

	cmp.setup.filetype({ "dap-repl", "dapui_watches" }, {
		sources = {
			{ name = "dap" },
		},
	})
	mappings.cmp()
	usercommands.cmp()
end

config()
