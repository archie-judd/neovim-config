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

return M
