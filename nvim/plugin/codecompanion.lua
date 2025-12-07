local function config()
	local autocommands = require("config.autocommands")
	local codecompanion = require("codecompanion")
	local mappings = require("config.mappings")
	local prompts = require("utils.codecompanion.prompts")
	
	local WINDOW_WIDTH = 0.4
	local DEFAULT_ADAPTER = "copilot"
	local DEFAULT_MODEL = "gpt-5-mini"
	codecompanion.setup({
		strategies = {
			-- Change the default chat adapter
			chat = {
				adapter = { name = DEFAULT_ADAPTER, model = DEFAULT_MODEL },
				keymaps = {
					-- make unreachable ( I use my own functions )
					send = {
						modes = { n = "<NOP>", i = "<NOP>" },
					},
					close = {
						modes = { n = "<NOP>", i = "<NOP>" },
					},
				},
				tools = {
					clipboard = {
						callback = "utils.codecompanion.tools.clipboard",
						description = "A tool for copying and pasting text to and from the clipboard",
						opts = {},
					},
					lua_cmd_runner = {
						callback = "utils.codecompanion.tools.lua_cmd_runner",
						description = "A tool for executing lua commands",
						opts = { requires_approval = true },
					},
					opts = {
						wait_timeout = 120000, -- 2 minutes
					},
				},
				variables = {
					["staged_diff"] = {
						callback = "utils.codecompanion.variables.staged_diff",
						description = "Share the output of `git diff --cached` with the LLM",
					},
				},
				slash_commands = {
					["file"] = {
						callback = "strategies.chat.slash_commands.catalog.file",
						description = "Insert a file",
						opts = {
							contains_code = true,
							max_lines = 1000,
							provider = "telescope",
						},
						keymaps = {
							modes = {
								n = { "<Space>f" },
							},
						},
					},
					["git_changed"] = {
						callback = "utils.codecompanion.slash_commands.git_changed_files",
						description = "Select a changed file within the git repository",
						opts = {
							contains_code = true,
							max_lines = 1000,
							provider = "telescope",
						},
						keymaps = {
							modes = {
								n = { "<Space>g" },
							},
						},
					},
					["buffer"] = {
						keymaps = {
							modes = {
								n = { "<Space>b" },
							},
						},
					},
				},
			},
			inline = { adapter = { name = DEFAULT_ADAPTER, model = DEFAULT_MODEL } },
			cmd = { adapter = { name = DEFAULT_ADAPTER, model = DEFAULT_MODEL } },
		},
		display = {
			chat = {
				window = {
					layout = "vertical",
					position = "right",
					border = "single",
					width = WINDOW_WIDTH,
				},
				intro_message = "",
				show_token_count = true,
				start_in_insert_mode = false,
			},
			debug_window = {
				-- this doesn't seem to work
				width = math.floor(0.5 * vim.o.columns),
				height = math.floor(0.5 * vim.o.lines),
			},
			diff = {
				enabled = true,
				provider = "inline",
			},
			action_palette = {
				provider = "telescope",
				opts = {
					show_default_actions = true,
					show_default_prompt_library = true,
				},
			},
		},
		prompt_library = {
			["Edit current buffer"] = prompts.edit_current_buffer,
			["Suggest commits"] = prompts.suggest_commits,
		},
		extensions = {
			history = {
				enabled = true,
				opts = {
					auto_generate_title = true,
					title_generation_opts = {
						adapter = DEFAULT_ADAPTER,
						model = DEFAULT_MODEL,
					},
					summary_generation_opts = { adapter = DEFAULT_ADAPTER, model = DEFAULT_MODEL },
				},
			},
		},
	})
	-- expand cc to CodeCompanion in the command lines
	vim.cmd("cabbrev cc CodeCompanion")
	-- register the markdown language for CodeCompanion
	-- vim.treesitter.language.register("markdown", "codecompanion")
	mappings.codecompanion()
	autocommands.codecompanion()
end
config()
