local config = function()
	local autocommands = require("config.autocommands")
	local diffview = require("diffview")
	local mappings = require("config.mappings")

	diffview.setup({
		file_panel = {
			listing_style = "list",
			win_config = { -- See ':h diffview-config-win_config'
				position = "left",
				width = 45,
				win_opts = {},
			},
		},
		keymaps = {
			file_panel = {
				["-"] = false,
			},
		},
		hooks = {
			hooks = {
				view_enter = function()
					vim.opt.autowriteall = true
				end,
				view_leave = function(view)
					for _, win in ipairs(vim.api.nvim_tabpage_list_wins(view.tabpage)) do
						local buf = vim.api.nvim_win_get_buf(win)
						if vim.bo[buf].modified and vim.bo[buf].modifiable and vim.bo[buf].buftype == "" then
							vim.api.nvim_buf_call(buf, function()
								vim.cmd("silent! write")
							end)
						end
					end
					vim.opt.autowriteall = false
				end,
			},
		},
	})
	mappings.diffview()
	autocommands.diffview()
end

local function load_on_keymap()
	local lazy_load_util = require("lib.lazy_load")
	lazy_load_util.load_plugin_on_keymaps(config, "diffview", { n = { "<Leader>gs", "<Leader>gh" } })
end

load_on_keymap()
