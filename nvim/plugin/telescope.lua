local config = function()
	local actions = require("telescope.actions")
	local autocommands = require("config.autocommands")
	local mappings = require("config.mappings")
	local telescope = require("telescope")
	local word_actions = require("telescope-words.actions")

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
					["<C-q>"] = actions.close,
					["<C-n>"] = actions.move_selection_next,
					["<C-p>"] = actions.move_selection_previous,
					["<C-s>"] = actions.send_to_qflist,
					["<M-s>"] = actions.send_selected_to_qflist,
				},
				i = {
					["<C-y>"] = actions.select_default,
					["<C-q>"] = actions.close,
					["<C-n>"] = actions.move_selection_next,
					["<C-p>"] = actions.move_selection_previous,
					["<C-s>"] = actions.send_to_qflist,
					["<M-s>"] = actions.send_selected_to_qflist,
				},
			},
		},
		extensions = {
			live_grep_args = { auto_quoting = true },
			fzf = {
				fuzzy = true, -- false will only do exact matching
				override_generic_sorter = true, -- override the generic sorter
				override_file_sorter = true, -- override the file sorter
				case_mode = "smart_case", -- or "ignore_case" or "respect_case"
				-- the default case_mode is "smart_case"
			},
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
				layout_config = { preview_width = 0.65 },
				similarity_depth = 3,
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
			marks = { mappings = { n = { ["dd"] = actions.delete_mark + actions.move_to_top } } },
		},
	})
	telescope.load_extension("live_grep_args")
	telescope.load_extension("fzf")
	telescope.load_extension("git_changed_files")
	mappings.telescope()
	autocommands.telescope()
end

vim.defer_fn(config, 0)
