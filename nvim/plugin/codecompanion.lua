local CODECOMPANION_LEADER = " "

local function config()
	local codecompanion = require("codecompanion")
	local mappings = require("config.mappings")
	local utils = require("lib.plugin.codecompanion.utils")
	local autocommands = require("config.autocommands")
	local adapters = require("codecompanion.adapters")

	vim.g.maplocalleader = CODECOMPANION_LEADER
	local WINDOW_WIDTH = 0.4
	local DEFAULT_ADAPTER = { name = "claude_code", model = "opus" }

	codecompanion.setup({
		adapters = {
			acp = {
				opts = {
					show_presets = false,
					show_model_choices = true,
				},
				claude_code = function()
					return adapters.extend("claude_code", {
						env = {
							CLAUDE_CODE_OAUTH_TOKEN = function()
								return nil
							end,
						},
					})
				end,
			},
			http = {
				opts = {
					show_presets = false,
					show_model_choices = true,
				},
				copilot = "copilot",
			},
		},
		interactions = {
			-- Change the default chat adapter
			chat = {
				adapter = DEFAULT_ADAPTER,
				keymaps = {
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
					add_current_buffer = {
						modes = { n = "<LocalLeader>b" },
						callback = utils.add_current_buffer_to_chat,
						description = "Add the current buffer to the chat context",
					},
				},
				variables = {
					["staged_diff"] = {
						callback = "lib.plugin.codecompanion.variables.staged_diff",
						description = "Share the output of `git diff --cached` with the LLM",
					},

					["diff"] = {
						callback = "lib.plugin.codecompanion.variables.diff",
						description = "Share the output of `git diff --cached` with the LLM",
						opts = {
							has_params = true,
						},
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
								n = { "<Space>ff" },
							},
						},
					},
					["changed_files"] = {
						callback = "lib.plugin.codecompanion.slash_commands.changed_files",
						description = "Select a changed file within the git repository",
						opts = {
							contains_code = true,
							max_lines = 1000,
							provider = "telescope",
						},
						keymaps = {
							modes = {
								n = { "<Space>fc" },
							},
						},
					},
					["buffer"] = {
						keymaps = {
							modes = {
								n = { "<Space>fb" },
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
				show_settings = false, -- Can't change adapter if this is true
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
					show_default_actions = false,
					show_default_prompts = false,
				},
			},
		},
		extensions = {
			history = {
				enabled = true,
				opts = {
					expiration_days = 7,
					auto_generate_title = false,
				},
			},
			spinner = {},
		},
	})
	-- register the markdown language for CodeCompanion
	vim.treesitter.language.register("markdown", "codecompanion")
	vim.cmd([[cab cc Codecompanion]])
	mappings.codecompanion()
	autocommands.codecompanion()
end

local function load_plugin_on_keymap()
	local lazy_load_util = require("lib.lazy_load")
	vim.g.maplocalleader = CODECOMPANION_LEADER
	lazy_load_util.load_plugin_on_keymaps(config, "codecompanion", {
		n = { "<LocalLeader>c", "<LocalLeader>n", "<LocalLeader>i", "<LocalLeader>a" },
		v = { "<LocalLeader>c", "<LocalLeader>n", "<LocalLeader>i", "<LocalLeader>a" },
	})
end

load_plugin_on_keymap()
