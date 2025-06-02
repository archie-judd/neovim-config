local autocommands = require("config.autocommands")
local codecompanion = require("codecompanion")
local mappings = require("config.mappings")
local prompts = require("utils.codecompanion.prompts")
local tools = require("utils.codecompanion.tools")

local function config()
	local WINDOW_WIDTH = 0.4
	codecompanion.setup({
		strategies = {
			-- Change the default chat adapter
			chat = {
				adapter = "copilot",
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
						-- change this to a module path when 15.13.0 (2025-06-01) is available
						callback = tools.module_dir .. "clipboard.lua",
						description = "A tool for copying and pasting text to and from the clipboard",
						opts = {},
					},
					lua_cmd_runner = {
						callback = tools.module_dir .. "lua_cmd_runner.lua",
						description = "A tool for executing lua commands",
						opts = { requires_approval = true },
					},
				},
				variables = {
					["diff"] = {
						callback = "utils.codecompanion.variables.diff",
						description = "Share the git diff for unstaged files with the llm",
					},
					["sdiff"] = {
						callback = "utils.codecompanion.variables.diff_staged",
						description = "Share the git diff for staged files with the llm",
					},
					["gfiles"] = {
						callback = "utils.codecompanion.variables.git_files",
						description = "Share the relative paths of all files in the git repository with the llm",
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
			inline = { adapter = "copilot" },
			agent = { adapter = "copilot" },
		},
		display = {
			chat = {
				window = {
					layout = "vertical",
					position = "right",
					border = "single",
					width = WINDOW_WIDTH,
				},
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
			["suggest commits"] = prompts.suggest_commits,
		},
	})
	mappings.codecompanion()
	autocommands.codecompanion()
	-- expand cc to CodeCompanion in the command lines
	vim.cmd("cabbrev cc CodeCompanion")
end

config()
