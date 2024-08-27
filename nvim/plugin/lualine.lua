local config = function()
	local lualine = require("lualine")
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
