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
			keymap = { preset = "none" },
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
					-- All available options
					opts = {
						-- A score offset applied to returned items.
						-- By default the highest score is 0 (item 1 has a score of -1, item 2 of -2 etc..).
						score_offset = 0,

						-- Default pointers define the lexical relations listed under each definition,
						-- see Pointer Symbols below.
						-- Default is as below ("antonyms", "similar to" and "also see").
						pointer_symbols = { "!", "&", "^" },
					},
				},

				-- Use the dictionary source
				dictionary = {
					name = "blink-cmp-words",
					module = "blink-cmp-words.dictionary",
					-- All available options
					opts = {
						-- The number of characters required to trigger completion.
						-- Set this higher if completion is slow, 3 is default.
						dictionary_search_threshold = 3,

						-- See above
						score_offset = 0,

						-- See above
						pointer_symbols = { "!", "&", "^" },
					},
				},
			},
			per_filetype = {
				text = { "dictionary", "thesaurus" },
				markdown = { "dictionary", "thesaurus" },
			},
		},
		appearance = { nerd_font_variant = "normal" },
		signature = { enabled = false }, -- Untill they implement permanent toggling
	})
	usercommands.cmp()
	mappings.cmp()
end

config()
