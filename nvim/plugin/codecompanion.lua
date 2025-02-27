local autocommands = require("config.autocommands")
local codecompanion = require("codecompanion")
local mappings = require("config.mappings")
local tools = require("utils.codecompanion.tools")

local function config()
	local CHAT_WINDOW_WIDTH = 0.4
	local CHAT_WINDOW_HEIGHT = 0.85

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
				agents = {
					tools = {
						["clipboard"] = {
							callback = tools.module_dir .. "clipboard.lua",
							description = "A tool for copying and pasting test to and from the clipboard buffer",
						},
						["lua_cmd_runner"] = {
							callback = tools.module_dir .. "lua_cmd_runner.lua",
							description = "A tool for executing lua commands",
							opts = { user_approval = true },
						},
					},
				},
				variables = {
					["diff"] = {
						callback = "utils.codecompanion.variables.diff",
						description = "Share the git diff for unstaged files with the llm",
					},
					["diff_staged"] = {
						callback = "utils.codecompanion.variables.diff_staged",
						description = "Share the git diff for staged files with the llm",
					},
				},
			},
			inline = { adapter = "copilot" },
		},
		display = {
			chat = {
				window = {
					layout = "float",
					width = CHAT_WINDOW_WIDTH,
					height = CHAT_WINDOW_HEIGHT,
					-- these are the row/col of the window's top-left corner
					row = math.floor(((vim.o.lines * (1 - CHAT_WINDOW_HEIGHT)) - 2) / 2),
					col = math.floor((vim.o.columns * (1.5 - CHAT_WINDOW_WIDTH)) / 2),
				},
				start_in_insert_mode = true,
			},
			debug_window = {
				-- this doesn't seem to work
				width = math.floor(0.5 * vim.o.columns),
				height = math.floor(0.5 * vim.o.lines),
			},
			diff = {
				enabled = true,
				provider = "mini_diff",
			},
			action_palette = {
				provider = "default", -- default|telescope|mini_pick
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
						content = "You are an experienced developer. You will be requested to make some changes to a provided buffer. Think carefully about where in the buffer any changes should go. Keep your responses concise and to the point. Don't include next-step suggestions.",
					},
					{
						role = "user",
						content = "@editor make the following changes to #buffer:  ",
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
						content = "Generate a concise commit message for a given git diff. The message should be descriptive and under 60 characters. Use lua_cmd_runner to execute a git fugitive commit command in the command line with nvim_feedkeys.",
					},
					{
						role = "user",
						content = '@lua_cmd_runner Here is the diff: #diff_stage\n\n Write a commit message and execute a git fugitive commit using vim.api.nvim_i `vim.api.nvim_feedkeys(":Git commit -m <commit-message>", "n", false)`. Set force to true to bypass approval, and ensure the user is in normal mode - you can use vim.cmd("stopinsert").',
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
end

config()
