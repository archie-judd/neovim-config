local autocommands = require("config.autocommands")
local codecompanion = require("codecompanion")
local mappings = require("config.mappings")
local prompts = require("utils.codecompanion.prompts")

local function config()
	local WINDOW_WIDTH = 0.4
	codecompanion.setup({
		strategies = {
			-- Change the default chat adapter
			chat = {
				adapter = {
					name = "copilot",
					model = "gpt-4o",
				},
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
				slash_commands = {
					["file"] = {
						callback = "strategies.chat.slash_commands.file",
						description = "Insert a file",
						opts = {
							contains_code = true,
							max_lines = 1000,
							provider = "telescope",
						},
					},
				},
			},
			inline = { adapter = { name = "copilot", model = "gpt-4o" } },
			cmd = { adapter = { name = "copilot", model = "gpt-4o" } },
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
				provider = "default",
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
						adapter = "copilot",
						model = "gpt-4o",
					},
					summary_generation_opts = { adapter = "copilot", model = "gpt-4o" },
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
