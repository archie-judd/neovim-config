local autocommands = require("config.autocommands")
local codecompanion = require("codecompanion")
local mappings = require("config.mappings")
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
			["Edit current buffer"] = {
				strategy = "chat",
				description = "Edit the current buffer",
				prompts = {
					{
						role = "system",
						[[You are an experienced developer. You will be requested to make some changes to a provided buffer. Keep 
your responses concise and to the point. Don't include next-step suggestions. When the user asks you a question about 
the buffer, edit it with your suggestions using your editor tool unless the user asks you to do otherwise. If you are 
asked to edit a function, make sure to include any decorators in the existing function when making your edits.]],
					},
					{
						role = "user",
						content = "@editor make the following changes to #buffer{watch}:  ",
					},
				},
				opts = {
					modes = { "n" },
					is_slash_cmd = true,
					short_name = "ecb",
					auto_submit = false,
					index = 1,
					stop_context_insertion = true,
					user_prompt = false,
				},
			},
			["Generate a commit message"] = {
				strategy = "chat",
				description = "Generate a commit message",
				prompts = {
					{
						role = "system",
						content = function()
							return [[
Generate a descriptive commit message for a given git diff. The message should be descriptive and under 60 characters. 
Use lua_cmd_runner to execute a git fugitive commit command in the command line with nvim_feedkeys.
]]
						end,
					},
					{
						role = "user",
						content = function()
							vim.g.codecompanion_auto_tool_mode = true
							return [[
@lua_cmd_runner Here is the git diff: #sdiff. 

Write a commit message and execute a git fugitive commit using the following commands: 

`vim.cmd("stopinsert");vim.api.nvim_feedkeys(":Git commit -m <commit-message>", "n", false)`
              ]]
						end,
					},
				},
				opts = {
					modes = { "n" },
					is_slash_cmd = true,
					short_name = "gcm",
					auto_submit = true,
					index = 2,
					stop_context_insertion = true,
					user_prompt = false,
				},
			},
		},
	})
	mappings.codecompanion()
	autocommands.codecompanion()
	-- expand cc to CodeCompanion in the command lines
	vim.cmd("cabbrev cc CodeCompanion")
end

config()
