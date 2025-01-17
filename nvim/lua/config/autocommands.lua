local core_utils = require("utils.core")
local dap = require("dap")
local diffview = require("diffview")
local mappings = require("config.mappings")
local panel = require("copilot.panel")

local M = {}

function M.core()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "python",
		callback = function(event)
			vim.o.colorcolumn = "89"
		end,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "lua",
		callback = function(event)
			vim.o.colorcolumn = "121"
		end,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "qf",
		callback = function(event)
			vim.keymap.set("n", "<C-c>", function()
				vim.api.nvim_buf_delete(event.buf, { force = true })
			end, {
				buffer = event.buf,
				silent = true,
				noremap = true,
				desc = "Quickfix: close",
			})
		end,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "typescript" },
		callback = function(event)
			vim.o.colorcolumn = "101"
			vim.o.tabstop = 2
			vim.o.shiftwidth = 2
			mappings.typescript()
		end,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "typescriptreact",
		callback = function(event)
			vim.o.colorcolumn = "101"
			vim.o.softtabstop = 2
			vim.o.shiftwidth = 2
			vim.o.expandtab = true
			mappings.typescript()
		end,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "haskell",
		callback = function(event)
			vim.o.tabstop = 8
			vim.o.softtabstop = 2
			vim.o.shiftwidth = 2
			vim.o.colorcolumn = "101"
		end,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "nix",
		callback = function(event)
			vim.o.tabstop = 2
			vim.o.shiftwidth = 2
		end,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "markdown",
		callback = function()
			vim.cmd("setlocal spell spelllang=en_gb")
			mappings.markdown_preview()
			mappings.vim_markdown_toc()
		end,
	})
	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function(event)
			vim.highlight.on_yank()
		end,
	})
end

function M.oil()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "oil",
		callback = function(event)
			vim.o.colorcolumn = ""
		end,
	})
	-- Disabling preview until https://github.com/stevearc/oil.nvim/issues/435 is resolved
	-- vim.api.nvim_create_autocmd("User", {
	-- 	pattern = "OilEnter",
	-- 	callback = vim.schedule_wrap(function(args)
	-- 		if vim.api.nvim_get_current_buf() == args.data.buf and oil.get_cursor_entry() then
	-- 			oil.open_preview()
	-- 		end
	-- 	end),
	-- })
end

function M.eyeliner()
	-- Set the eyeliner highlights to be color-scheme dependent
	vim.api.nvim_create_autocmd("ColorScheme", {
		pattern = "*",
		callback = function()
			local boolean_hl = vim.api.nvim_get_hl(0, { name = "boolean" })
			local error_hl = vim.api.nvim_get_hl(0, { name = "error" })
			local comment_hl = vim.api.nvim_get_hl(0, { name = "comment" })
			vim.api.nvim_set_hl(0, "EyelinerDimmed", comment_hl)
			vim.api.nvim_set_hl(0, "EyelinerPrimary", boolean_hl)
			vim.api.nvim_set_hl(0, "EyelinerSecondary", error_hl)
		end,
	})
end

function M.diffview()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "DiffviewFiles" },
		callback = function(event)
			vim.keymap.set("n", "<C-c>", function()
				diffview.close()
			end, {
				buffer = event.buf,
				noremap = true,
				silent = true,
				desc = "Diffview: close",
			})
		end,
	})
	-- make sure we can't read buffers into the diffview file panel
	vim.api.nvim_create_autocmd("BufWinEnter", {
		pattern = "DiffviewFilePanel",
		callback = function(event)
			local winid = vim.api.nvim_get_current_win()
			vim.wo[winid].winfixbuf = true
		end,
	})
end

function M.telescope()
	vim.api.nvim_create_autocmd("User", {
		pattern = { "TelescopeFindPre" },
		callback = function(event)
			-- close oil if it's open to avoid reading the telescope results into its window
			core_utils.close_buffer_by_filetype_pattern("oil", { force = true })
		end,
	})
end

function M.lspconfig()
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspConfig", {}),
		callback = function(event)
			mappings.lspconfig(event.buf)
		end,
	})
end

function M.copilot()
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "copilot:*/*",
		callback = function(event)
			vim.keymap.set("n", "<C-c>", function()
				vim.api.nvim_buf_delete(event.buf, { force = true })
			end, {
				buffer = event.buf,
				noremap = true,
				silent = true,
				desc = "Copilot: Close the panel",
			})
			vim.keymap.set("n", "<C-n>", panel.jump_next, {
				buffer = event.buf,
				noremap = true,
				silent = true,
				desc = "Copilot: Next panel suggestion",
			})
			vim.keymap.set("n", "<C-p>", panel.jump_prev, {
				buffer = event.buf,
				noremap = true,
				silent = true,
				desc = "Copilot: Previous panel suggestion",
			})
			vim.keymap.set("n", "<C-y>", panel.accept, {
				buffer = event.buf,
				noremap = true,
				silent = true,
				desc = "Copilot: Accept current panel suggestion",
			})
			vim.keymap.set("n", "<C-r>", panel.refresh, {
				buffer = event.buf,
				noremap = true,
				silent = true,
				desc = "Copilot: Refresh panel suggestions",
			})
		end,
	})
end

return M
