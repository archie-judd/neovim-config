local config = function()
	local actions = require("telescope.actions")
	local autocommands = require("config.autocommands")
	local mappings = require("config.mappings")
	local telescope = require("telescope")

	telescope.setup({
		defaults = {
			path_display = { "truncate" },
			layout_config = {
				width = 0.75,
				height = 0.75,
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
					["<C-c>"] = actions.close,
					["<C-n>"] = actions.move_selection_next,
					["<C-p>"] = actions.move_selection_previous,
					["<C-q>"] = actions.send_to_qflist,
					["<M-q>"] = actions.send_selected_to_qflist,
				},
				i = {
					["<C-c>"] = actions.close,
					["<C-n>"] = actions.move_selection_next,
					["<C-p>"] = actions.move_selection_previous,
					["<C-q>"] = actions.send_to_qflist,
					["<M-q>"] = actions.send_selected_to_qflist,
				},
			},
		},
		extensions = { live_grep_args = { auto_quoting = true } },
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
	mappings.telescope()
	autocommands.telescope()
end

config()
