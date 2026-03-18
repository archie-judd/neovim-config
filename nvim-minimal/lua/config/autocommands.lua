local M = {}

function M.core()
	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function(event)
			vim.highlight.on_yank()
		end,
	})
end

function M.oil()
	local oil = require("oil")
	vim.api.nvim_create_autocmd("User", {
		pattern = "OilEnter",
		callback = vim.schedule_wrap(function(args)
			if vim.api.nvim_get_current_buf() == args.data.buf and oil.get_cursor_entry() then
				oil.open_preview()
			end
		end),
	})
end

function M.telescope()
	local core_utils = require("lib.core")
	vim.api.nvim_create_autocmd("User", {
		pattern = { "TelescopeFindPre" },
		callback = function(event)
			core_utils.close_buffer_by_filetype_pattern("oil", { force = true })
		end,
	})
end

function M.terminal()
	local terminal = require("lib.plugin.terminal")
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "*",
		callback = function(event)
			if event.buf == terminal.state.term_buffer then
				vim.keymap.set(
					{ "n", "t" },
					"<C-q>",
					terminal.close,
					{ buffer = event.buf, noremap = true, silent = true, desc = "Terminal: close" }
				)
			end
		end,
	})

	vim.api.nvim_create_autocmd("TermOpen", {
		pattern = "*",
		callback = function(event)
			vim.wo.number = false
			vim.wo.relativenumber = false
			vim.wo.signcolumn = "no"
			if event.buf == terminal.state.term_buffer then
				vim.keymap.set({ "n", "t" }, "<C-q>", function()
					terminal.close()
				end, { buffer = event.buf, noremap = true, silent = true, desc = "Terminal: close" })
			end
		end,
	})
end

return M
