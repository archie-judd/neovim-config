local lualine = require("lualine")

local config = function()
	lualine.setup({
		options = {
			theme = "catppuccin",
			section_separators = "",
			component_separators = "",
			ignore_focus = {
				"dap-repl",
			},
		},
		sections = {
			lualine_a = { { "branch" } },
			lualine_b = { { "diff" }, { "diagnostics" } },
			lualine_c = {
				{
					"filename",
					path = 1,
					file_status = false,
					newfile_status = false,
					symbols = { modified = "", readonly = "", unnamed = "", newfile = "" },
				},
			},
		},
	})
end

config()
