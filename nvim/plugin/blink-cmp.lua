local blink = require("blink.cmp")
local cmp_dap = require("cmp_dap")
local mappings = require("config.mappings")
local usercommands = require("config.usercommands")

local function config()
	blink.setup({
		enabled = function()
			return (vim.api.nvim_get_option_value("buftype", { buf = 0 }) ~= "prompt" or cmp_dap.is_dap_buffer())
				and vim.g.cmp_enabled ~= false
		end,

		keymap = { preset = "none" },

		cmdline = {
			enabled = true,
			keymap = {
				["C-y"] = { "accept" },
				["C-e"] = { "cancel" },
				["C-n"] = { "select_next" },
				["C-p"] = { "select_prev" },
			},
			completion = { menu = { auto_show = true } },
		},

		term = { enabled = true, keymap = { preset = "none" } },

		completion = {
			keyword = { range = "full" },
			accept = { auto_brackets = { enabled = false } },
			list = { selection = { preselect = false, auto_insert = false } },

			menu = {
				auto_show = true,
				draw = {
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind_icon", "kind" },
					},
				},
			},
			documentation = { auto_show = false },
			ghost_text = { enabled = true },
		},

		sources = {
			default = { "lsp", "path", "lazydev" },
			providers = {
				dap = { name = "dap", module = "blink.compat.source" },
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
				thesaurus = {
					name = "blink-cmp-words",
					module = "blink-cmp-words.thesaurus",
					opts = {
						score_offset = 0,
						definition_pointers = { "!", "&", "^" },
					},
				},
				dictionary = {
					name = "blink-cmp-words",
					module = "blink-cmp-words.dictionary",
					opts = {
						dictionary_search_threshold = 3,
						score_offset = 0,
						definition_pointers = { "!", "&", "^" },
					},
				},
			},
			per_filetype = {
				["dap-repl"] = { "dap" },
				markdown = { "thesaurus" },
			},
		},
		appearance = { nerd_font_variant = "normal" },
		signature = { enabled = false }, -- Untill they implement permanent toggling
	})
	usercommands.cmp()
	mappings.cmp()
end

config()
