local autocommands = require("config.autocommands")
local layout = require("oil.layout")
local mappings = require("config.mappings")
local oil = require("oil")

local config = function()
	oil.setup({
		keymaps = { ["<C-p>"] = false },
		float = {
			override = function()
				local total_width = vim.o.columns
				local total_height = layout.get_editor_height()
				local width = math.floor(vim.o.columns * 0.7)
				local height = math.floor(vim.o.lines * 0.7)
				local row = math.floor((total_height - height) / 2)
				local col = math.floor((total_width - width) / 2) - 1 -- adjust for border width
				local win_opts = {
					relative = "editor",
					width = width,
					height = height,
					row = row,
					col = col,
					border = "rounded",
					zindex = 45,
				}
				return win_opts
			end,
			preview_split = "right",
		},
	})

	mappings.oil()
	autocommands.oil()
end

config()
