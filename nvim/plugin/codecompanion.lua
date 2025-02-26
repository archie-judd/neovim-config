local autocommands = require("config.autocommands")
local codecompanion = require("codecompanion")
local mappings = require("config.mappings")

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
				-- width = 95,
				-- height = 10,
				-- prompt = "Prompt ", -- Prompt used for interactive LLM calls
				provider = "default", -- default|telescope|mini_pick
				opts = {
					show_default_actions = false,
					show_default_prompt_library = false,
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
						content = "You are an experienced developer. Keep your responses concise and to the point. Don't include next-step suggestions.",
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
					user_prompt = true,
				},
			},
		},
	})
	mappings.codecompanion()
	autocommands.codecompanion()
end

config()
