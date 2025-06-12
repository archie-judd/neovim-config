local codecompanion_utils = require("utils.codecompanion.chat")
local core_utils = require("utils.core")
local dap = require("dap")
local dap_utils = require("utils.dap")
local diff_utils = require("utils.diff")
local diffview = require("diffview")
local mappings = require("config.mappings")
local maximise = require("maximise")
local oil = require("oil")
local terminal = require("terminal")

local M = {}

function M.core()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "python",
		callback = function(event)
			vim.o.colorcolumn = "89"
			vim.o.expandtab = true
			vim.o.shiftwidth = 4
			vim.o.tabstop = 4
			vim.o.softtabstop = 4
			vim.o.textwidth = 88
		end,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "lua",
		callback = function(event)
			vim.o.colorcolumn = "121"
			vim.opt_local.expandtab = true
			vim.opt_local.shiftwidth = 2
			vim.opt_local.tabstop = 2
			vim.opt_local.softtabstop = 2
		end,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "qf",
		callback = function(event)
			vim.keymap.set("n", "<C-q>", function()
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

	vim.api.nvim_create_autocmd("OptionSet", {
		pattern = "diff",
		callback = function(event)
			-- Exclude diffview buffers
			local bufname = vim.api.nvim_buf_get_name(event.buf)
			if not string.match(bufname, "diffview") then
				vim.keymap.set("n", "<Leader>cd", function()
					diff_utils.close(1)
				end, {
					buffer = event.buf,
					silent = true,
					noremap = true,
					desc = "Diff: close, keeping leftmost buffer",
				})
				vim.keymap.set("n", "[C", diff_utils.go_to_first_conflict, {
					buffer = event.buf,
					silent = true,
					noremap = true,
					desc = "Diff: move to first conflict and center",
				})
				vim.keymap.set("n", "]C", diff_utils.go_to_last_conflict, {
					buffer = event.buf,
					silent = true,
					noremap = true,
					desc = "Diff: move to last conflict and center",
				})
			end
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
	vim.api.nvim_create_autocmd("User", {
		pattern = "OilEnter",
		callback = vim.schedule_wrap(function(args)
			if vim.api.nvim_get_current_buf() == args.data.buf and oil.get_cursor_entry() then
				oil.open_preview()
			end
		end),
	})
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
			vim.keymap.set("n", "<C-q>", function()
				diffview.close()
			end, {
				buffer = event.buf,
				noremap = true,
				silent = true,
				desc = "Diffview: close",
			})
			vim.keymap.set("n", "gr", function()
				diffview.close()
				diffview.open()
			end, {
				buffer = event.buf,
				noremap = true,
				silent = true,
				desc = "Diffview: refresh",
			})
		end,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "DiffviewFileHistory" },
		callback = function(event)
			vim.keymap.set("n", "<C-q>", function()
				diffview.close()
			end, {
				buffer = event.buf,
				noremap = true,
				silent = true,
				desc = "Diffview: close file history",
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
	-- make sure we can't read buffers into the diffview file panel
	vim.api.nvim_create_autocmd("BufWinEnter", {
		pattern = "DiffviewFileHistoryPanel",
		callback = function(event)
			local winid = vim.api.nvim_get_current_win()
			vim.wo[winid].winfixbuf = true
		end,
	})
	vim.api.nvim_create_autocmd("User", {
		pattern = "DiffviewDiffBufWinEnter",
		callback = function(event)
			vim.keymap.set("n", "[C", diff_utils.go_to_first_conflict, {
				buffer = event.buf,
				silent = true,
				noremap = true,
				desc = "Diff: move to first conflict and center",
			})
			vim.keymap.set("n", "]C", diff_utils.go_to_last_conflict, {
				buffer = event.buf,
				silent = true,
				noremap = true,
				desc = "Diff: move to last conflict and center",
			})
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

function M.codecompanion()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "codecompanion",
		callback = function(event)
			vim.keymap.set(
				{ "n", "i" },
				"<C-q>",
				codecompanion_utils.close,
				{ buffer = event.buf, silent = true, noremap = true, desc = "CodeCompanion: close chat" }
			)
			vim.keymap.set(
				{ "n", "i" },
				"<C-s>",
				codecompanion_utils.submit,
				{ buffer = event.buf, silent = true, noremap = true, desc = "CodeCompanion: submit prompt" }
			)
		end,
	})
end

function M.maximise()
	vim.api.nvim_create_autocmd("WinLeave", {
		callback = function()
			maximise.restore_if_maximised()
		end,
	})
end

function M.terminal()
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "*",
		callback = function(event)
			if event.buf == vim.g.term_buffer then
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
			if event.buf == vim.g.term_buffer then
				vim.keymap.set({ "n", "t" }, "<C-q>", function()
					terminal.close()
				end, { buffer = event.buf, noremap = true, silent = true, desc = "Termninal: close" })
			end
		end,
	})

	vim.api.nvim_create_autocmd("ExitPre", {
		pattern = "*",
		callback = function(event)
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
					vim.api.nvim_buf_delete(buf, { force = true })
				end
			end
		end,
	})
end

function M.dap()
	vim.api.nvim_create_autocmd("BufFilePost", {
		pattern = "*\\[dap-terminal\\]*",
		callback = function(event)
			vim.keymap.set("n", "<C-q>", dap_utils.quit, {
				buffer = event.buf,
				silent = true,
				noremap = true,
				desc = "Dap: quit debug session",
			})
			dap.repl.open({ number = false, relativenumber = false }, "split")
		end,
	})
	vim.api.nvim_create_autocmd("BufFilePost", {
		pattern = "*\\[dap-terminal\\]*",
		callback = function(event)
			vim.keymap.set("n", "<C-q>", dap_utils.quit, {
				buffer = event.buf,
				silent = true,
				noremap = true,
				desc = "Dap: quit debug session",
			})
			dap.repl.open({ number = false, relativenumber = false }, "split")
		end,
	})
end

return M
