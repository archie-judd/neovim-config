local copilot_chat = require("CopilotChat")

local function config()
	copilot_chat.setup({
		window = {
			layout = "float",
			width = 0.5,
			height = 0.95,
			relative = "editor",
			border = "single",
			row = 0,
			col = math.floor(3 * (vim.o.columns / 4)), -- column position of the window, default is centered
		},
	})
end

config()
