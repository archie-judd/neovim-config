local actions = require("telescope.actions")
local autocommands = require("config.autocommands")
local mappings = require("config.mappings")
local telescope = require("telescope")
local word_actions = require("telescope-words.actions")

local config = function()
	telescope.setup({
		defaults = {
			path_display = { "truncate" },
			layout_config = {
				width = 0.75,
				height = 0.75,
				scroll_speed = 4,
			},
			vimgrep_arguments = {
				"rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
			},
			mappings = {
				n = {
					["<C-y>"] = actions.select_default,
					["<C-c>"] = actions.close,
					["<C-n>"] = actions.move_selection_next,
					["<C-p>"] = actions.move_selection_previous,
					["<C-q>"] = actions.send_to_qflist,
					["<M-q>"] = actions.send_selected_to_qflist,
				},
				i = {
					["<C-y>"] = actions.select_default,
					["<C-c>"] = actions.close,
					["<C-n>"] = actions.move_selection_next,
					["<C-p>"] = actions.move_selection_previous,
					["<C-q>"] = actions.send_to_qflist,
					["<M-q>"] = actions.send_selected_to_qflist,
				},
			},
		},
		extensions = {
			live_grep_args = { auto_quoting = true },
			telescope_words = {
				mappings = {
					n = {
						["<C-y>"] = word_actions.replace_word_under_cursor,
						["<CR>"] = word_actions.replace_word_under_cursor,
					},
					i = {
						["<C-y>"] = word_actions.replace_word_under_cursor,
						["<CR>"] = word_actions.replace_word_under_cursor,
					},
				},
			},
		},
		pickers = {
			buffers = {
				mappings = {
					n = {
						["dd"] = actions.delete_buffer,
					},
				},
			},
			find_files = {
				find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
			},
			--marks = { mappings = { n = { ["dd"] = actions.delete_mark + actions.move_to_top } } }, -- not released yet
		},
	})
	telescope.load_extension("live_grep_args")
	telescope.load_extension("telescope_words")
	mappings.telescope()
	autocommands.telescope()
end
config()
