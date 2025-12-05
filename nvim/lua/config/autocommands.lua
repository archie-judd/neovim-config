local codecompanion = require("codecompanion")
local conform = require("conform")
local core_utils = require("utils.core")
local dap = require("dap")
local dap_utils = require("utils.dap")
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
		end,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "lua",
		callback = function(event)
			vim.o.colorcolumn = "121"
			vim.o.expandtab = true
			vim.o.shiftwidth = 2
			vim.o.tabstop = 2
			vim.o.softtabstop = 2
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
		pattern = { "html", "htm", "xhtml", "xml", "svg" },
		callback = function(event)
			vim.o.colorcolumn = "120" -- Longer lines common in HTML
			vim.o.tabstop = 2
			vim.o.shiftwidth = 2
			vim.o.expandtab = true
		end,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "css", "scss", "sass", "less" },
		callback = function(event)
			vim.o.colorcolumn = "80"
			vim.o.tabstop = 2
			vim.o.shiftwidth = 2
			vim.o.expandtab = true
		end,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "javascript" },
		callback = function(event)
			vim.o.colorcolumn = "80"
			vim.o.tabstop = 2
			vim.o.shiftwidth = 2
			vim.o.expandtab = true
		end,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "typescript" },
		callback = function(event)
			vim.o.colorcolumn = "101"
			vim.o.tabstop = 2
			vim.o.shiftwidth = 2
			vim.o.expandtab = true
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
	vim.api.nvim_create_autocmd("FileType", {
		callback = function(event)
			local buf = event.buf
			local filetype = vim.bo[buf].filetype
			local lang = vim.treesitter.language.get_lang(filetype)
			if lang then
				local ok, parser = pcall(vim.treesitter.get_parser, buf, lang)
				if ok and parser then
					vim.treesitter.start(buf, lang)
				end
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
				diffview.open({})
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
	-- make sure we can't read buffers into the diffview file panel
	vim.api.nvim_create_autocmd("BufWinEnter", {
		pattern = "DiffviewFileHistoryPanel",
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

function M.codecompanion()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "codecompanion",
		callback = function(event)
			vim.keymap.set({ "n", "i" }, "<C-q>", function()
				local chat = codecompanion.last_chat()

				if chat ~= nil and chat.ui:is_visible() and chat.bufnr == event.buf then
					chat.ui:hide()
				else
					core_utils.close_active_or_topmost_floating_window(true)
				end
			end, { buffer = event.buf, silent = true, noremap = true, desc = "CodeCompanion: hide chat if open" })
			vim.keymap.set({ "n", "i" }, "<C-s>", function()
				local chat = codecompanion.last_chat()
				if chat ~= nil then
					chat:submit()
					vim.cmd("stopinsert")
				end
			end, { buffer = event.buf, silent = true, noremap = true, desc = "CodeCompanion: submit prompt" })
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
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "dap-repl",
		callback = function(event)
			vim.keymap.set("n", "<C-q>", dap_utils.quit, {
				buffer = event.buf,
				silent = true,
				noremap = true,
				desc = "Dap: quit debug session",
			})
		end,
	})
end

function M.conform()
	vim.api.nvim_create_autocmd("BufWritePre", {
		desc = "Format before save",
		pattern = "*",
		group = vim.api.nvim_create_augroup("FormatConfig", { clear = true }),
		callback = function(ev)
			local conform_opts = { bufnr = ev.buf, lsp_format = "fallback", timeout_ms = 2000 }
			local client = vim.lsp.get_clients({ name = "ts_ls", bufnr = ev.buf })[1]

			if not client then
				conform.format(conform_opts)
				return
			end

			local request_result = client:request_sync("workspace/executeCommand", {
				command = "_typescript.organizeImports",
				arguments = { vim.api.nvim_buf_get_name(ev.buf) },
			})

			if request_result and request_result.err then
				vim.notify(request_result.err.message, vim.log.levels.ERROR)
				return
			end

			conform.format(conform_opts)
		end,
	})
end

return M
