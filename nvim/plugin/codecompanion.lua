local CODECOMPANION_LEADER = " "

local function config()
	local codecompanion = require("codecompanion")
	local mappings = require("config.mappings")
	local user_commands = require("config.usercommands")
	local prompts = require("lib.plugin.codecompanion.prompts")
	local utils = require("lib.plugin.codecompanion.utils")
	local copilot_acp = require("lib.plugin.codecompanion.adapters.copilot_acp")

	vim.g.maplocalleader = CODECOMPANION_LEADER
	local WINDOW_WIDTH = 0.4
	local DEFAULT_ADAPTER = { name = "copilot_http", model = "claude-haiku-4.5" }

	codecompanion.setup({
		adapters = {
			acp = {
				opts = {
					show_presets = false,
					show_model_choices = true,
				},
				claude_code = "claude_code",
				copilot_acp = copilot_acp,
			},
			http = {
				opts = {
					show_presets = false,
					show_model_choices = true,
				},
				copilot_http = "copilot",
			},
		},
		interactions = {
			-- Change the default chat adapter
			chat = {
				adapter = DEFAULT_ADAPTER,
				keymaps = {
					-- make unreachable ( I use my own functions )
					send = {
						modes = { n = "<C-s>", i = "<C-s>" },
						callback = utils.send_prompt,
					},
					close = {
						modes = { n = "<C-q>", i = "<C-q>" },
						callback = utils.close_chat,
					},
					change_adapter = {
						modes = { n = "ga" },
						callback = utils.change_chat_adapter,
					},
				},
				tools = {
					clipboard = {
						callback = "lib.plugin.codecompanion.tools.clipboard",
						description = "A tool for copying and pasting text to and from the clipboard",
						opts = {},
					},
					lua_cmd_runner = {
						callback = "lib.plugin.codecompanion.tools.lua_cmd_runner",
						description = "A tool for executing lua commands",
						opts = { requires_approval = true },
					},
					opts = {
						wait_timeout = 120000, -- 2 minutes
					},
				},
				variables = {
					["staged_diff"] = {
						callback = "lib.plugin.codecompanion.variables.staged_diff",
						description = "Share the output of `git diff --cached` with the LLM",
					},
				},
				slash_commands = {
					["file"] = {
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
						callback = "lib.plugin.codecompanion.slash_commands.git_changed_files",
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
		},
		extensions = {
			history = {
				enabled = true,
				opts = {
					expiration_days = 7,
					auto_generate_title = true,
					title_generation_opts = {
						adapter = DEFAULT_ADAPTER.name,
						model = DEFAULT_ADAPTER.model,
					},
					summary_generation_opts = { adapter = DEFAULT_ADAPTER.name, model = DEFAULT_ADAPTER.model },
				},
			},
		},
	})
	-- register the markdown language for CodeCompanion
	vim.treesitter.language.register("markdown", "codecompanion")
	vim.cmd([[cab cc Codecompanion]])
	mappings.codecompanion()
end

local function load_plugin_on_keymap()
	local lazy_load_util = require("lib.lazy_load")
	vim.g.maplocalleader = CODECOMPANION_LEADER
	lazy_load_util.load_plugin_on_keymaps(config, "codecompanion", {
		n = { "<LocalLeader>c", "<LocalLeader>n", "<LocalLeader>i" },
		v = { "<LocalLeader>c", "<LocalLeader>n", "<LocalLeader>i" },
	})
end

load_plugin_on_keymap()
