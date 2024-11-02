local config = function()
	local cmp = require("cmp")
	local cmp_dap = require("cmp_dap")
	local copilot_comparators = require("copilot_cmp.comparators")

	cmp.setup({
		enabled = function()
			local enabled = (
				vim.api.nvim_get_option_value("buftype", { buf = 0 }) ~= "prompt" or cmp_dap.is_dap_buffer()
			)
			return enabled
		end,
		view = {
			docs = {
				auto_open = false,
			},
		},
		completion = { completeopt = "menu,menuone,noinsert" },
		mapping = cmp.mapping.preset.insert({
			["<C-f>"] = cmp.mapping({ i = cmp.mapping.complete() }),
			["<C-g>"] = cmp.mapping(function()
				if cmp.visible_docs() then
					cmp.close_docs()
				else
					cmp.open_docs()
				end
			end),
			["<C-u>"] = cmp.mapping({
				i = function(fallback)
					if cmp.visible() then
						cmp.mapping.scroll_docs(-4)
					else
						fallback()
					end
				end,
			}),
			["<C-d>"] = cmp.mapping({
				i = function(fallback)
					if cmp.visible() then
						cmp.mapping.scroll_docs(4)
					else
						fallback()
					end
				end,
			}),
			["<C-p>"] = cmp.mapping({
				c = function()
					if cmp.visible() then
						cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
					end
				end,
				i = function(fallback)
					if cmp.visible() then
						cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
					else
						fallback()
					end
				end,
			}),
			["<C-e>"] = cmp.mapping.abort(),
			["<C-y>"] = cmp.mapping.confirm({ select = true }),
		}),
		sources = cmp.config.sources({
			{ name = "copilot" },
			{ name = "nvim_lsp" },
			{ name = "nvim_lsp_signature_help" },
		}),
		sorting = {
			comparators = {
				cmp.config.compare.offset,
				cmp.config.compare.exact,
				copilot_comparators.prioritize,
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
end

config()
