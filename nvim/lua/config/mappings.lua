-- It's useful to have core mappings in one file, so accidental remaps can be easily spotted.
local M = {}
function M.core()
	-- Set mapleader
	vim.g.mapleader = ";"
	vim.keymap.set("i", "<C-x>", "<C-x>", { silent = true, noremap = true })

	-- Close floating windows
	vim.keymap.set("n", "<C-c>", ":fc<CR>", { silent = true, noremap = true, desc = "Floating windows: close topmost" })

	-- Hack for easy de-highlighting
	vim.keymap.set(
		"n",
		"<CR>",
		":noh <CR> <CR>",
		{ silent = true, noremap = true, desc = "Highlight: de-highlight and then press enter" }
	)

	-- Keep cursor central when jumping half pages
	vim.keymap.set(
		"n",
		"<C-d>",
		"<C-d>zz",
		{ noremap = true, silent = true, desc = "Movement: move cursor half page down and center screen" }
	)
	vim.keymap.set(
		"n",
		"<C-u>",
		"<C-u>zz",
		{ noremap = true, silent = true, desc = "Movement: move cursor half page up and center screen" }
	)

	-- Keep cursor central when jump from search results
	vim.keymap.set(
		"n",
		"n",
		"nzzzv",
		{ noremap = true, silent = true, desc = "Search: move to next item and center screen" }
	)
	vim.keymap.set(
		"n",
		"N",
		"Nzzzv",
		{ noremap = true, silent = true, desc = "Search: move to previous item and center screen" }
	)

	-- Moving between windows
	vim.keymap.set("n", "<C-h>", function()
		vim.cmd.wincmd("h")
	end, { silent = true, noremap = true, desc = "Windows: move left to the next window" })
	vim.keymap.set("n", "<C-l>", function()
		vim.cmd.wincmd("l")
	end, { silent = true, noremap = true, desc = "Windows: move right to the next window" })
	vim.keymap.set("n", "<C-j>", function()
		vim.cmd.wincmd("j")
	end, { silent = true, noremap = true, desc = "Windows: move down to the next window" })
	vim.keymap.set("n", "<C-k>", function()
		vim.cmd.wincmd("k")
	end, { silent = true, noremap = true, desc = "Windows: move up to the next window" })

	-- Resizing windows
	vim.keymap.set("n", "<M-k>", function()
		vim.cmd(":horizontal resize +5")
	end, { silent = true, noremap = true, desc = "Windows: increase window vertical size" })
	vim.keymap.set("n", "<M-j>", function()
		vim.cmd(":horizontal resize -5")
	end, { silent = true, noremap = true, desc = "Windows: decease window vertical size" })
	vim.keymap.set("n", "<M-l>", function()
		vim.cmd(":vertical resize +5")
	end, { silent = true, noremap = true, desc = "Windows: increase window horizontal size" })
	vim.keymap.set("n", "<M-h>", function()
		vim.cmd(":vertical resize -5")
	end, { silent = true, noremap = true, desc = "Windows: decrease window horizontal size" })

	-- Moving windows themselves
	vim.keymap.set("n", "<M-S-h>", function()
		vim.cmd.wincmd("H")
	end, { silent = true, noremap = true, desc = "Windows: move window leftward" })
	vim.keymap.set("n", "<M-S-l>", function()
		vim.cmd.wincmd("L")
	end, { silent = true, noremap = true, desc = "Windows: move window rightwards" })
	vim.keymap.set("n", "<M-S-j>", function()
		vim.cmd.wincmd("J")
	end, { silent = true, noremap = true, desc = "Windows: move window downwards" })
	vim.keymap.set("n", "<M-S-k>", function()
		vim.cmd.wincmd("K")
	end, { silent = true, noremap = true, desc = "Windows: move window upwards" })

	-- Tabs
	vim.keymap.set("n", "]t", vim.cmd.tabnext, { silent = true, noremap = true, desc = "Tabs: move to the next tab" })
	vim.keymap.set(
		"n",
		"[t",
		vim.cmd.tabprevious,
		{ silent = true, noremap = true, desc = "Tabs: move to the previous tab" }
	)

	-- Buffers
	vim.keymap.set(
		"n",
		"]b",
		vim.cmd.bnext,
		{ silent = true, noremap = true, desc = "Buffers: move to the next buffer" }
	)
	vim.keymap.set(
		"n",
		"[b",
		vim.cmd.bprevious,
		{ silent = true, noremap = true, desc = "Buffers: move to the previous buffer" }
	)

	-- Diagnostics
	vim.keymap.set(
		"n",
		"[d",
		vim.diagnostic.goto_prev,
		{ silent = true, noremap = true, desc = "Diagnostics: go to previous diagnostic issue" }
	)
	vim.keymap.set(
		"n",
		"]d",
		vim.diagnostic.goto_next,
		{ silent = true, noremap = true, desc = "Diagnostics: go to next diagnostic issue" }
	)

	vim.keymap.set(
		"n",
		"[q",
		":cprev<CR>",
		{ silent = true, noremap = true, desc = "Quickfix: go to previous location" }
	)
	vim.keymap.set("n", "]q", ":cnext<CR>", { silent = true, noremap = true, desc = "Quickfix: go to next location" })

	-- Escape Terminal
	vim.keymap.set(
		"t",
		"<Esc><Esc>",
		"<C-<Bslash>><C-n>",

		{ silent = true, noremap = true, desc = "Terminal: exit terminal mode" }
	)

	vim.keymap.set("n", "<Leader>o", "jO<Esc>k", { silent = true, noremap = true, desc = "Insert line: below" })
	vim.keymap.set("n", "<Leader>O", "ko<Esc>j", { silent = true, noremap = true, desc = "Insert line: above" })
end

function M.nvim_tmux_navigation()
	local nvim_tmux_navigation = require("nvim-tmux-navigation")

	vim.keymap.set(
		"n",
		"<C-h>",
		nvim_tmux_navigation.NvimTmuxNavigateLeft,
		{ silent = true, noremap = true, desc = "Tmux: move left to the next window or tmux pane" }
	)
	vim.keymap.set(
		"n",
		"<C-j>",
		nvim_tmux_navigation.NvimTmuxNavigateDown,
		{ silent = true, noremap = true, desc = "Tmux: move down to the next window or tmux pane" }
	)
	vim.keymap.set(
		"n",
		"<C-k>",
		nvim_tmux_navigation.NvimTmuxNavigateUp,
		{ silent = true, noremap = true, desc = "Tmux: move up to the next window or tmux pane" }
	)
	vim.keymap.set(
		"n",
		"<C-l>",
		nvim_tmux_navigation.NvimTmuxNavigateRight,
		{ silent = true, noremap = true, desc = "Tmux: move right to the next window or tmux pane" }
	)
end

---@param bufnr integer
function M.lspconfig(bufnr)
	local telescope_builtin = require("telescope.builtin")

	vim.keymap.set(
		"n",
		"<C-]>",
		telescope_builtin.lsp_definitions,
		{ silent = true, noremap = true, buffer = bufnr, desc = "Lsp: go to definition with telescope" }
	)
	vim.keymap.set(
		"n",
		"<Leader>td",
		telescope_builtin.lsp_type_definitions,
		{ silent = true, noremap = true, buffer = bufnr, desc = "Lsp: go to type definition with telescope" }
	)
	vim.keymap.set("n", "<Leader>lr", function()
		telescope_builtin.lsp_references({ show_line = false })
	end, { silent = true, noremap = true, buffer = bufnr, desc = "Lsp: list references" })
	vim.keymap.set(
		{ "n" },
		"<C-g>",
		vim.lsp.buf.hover,
		{ silent = true, noremap = true, buffer = bufnr, desc = "Lsp: hover" }
	)
	vim.keymap.set("n", "<C-s>", function()
		vim.lsp.buf.signature_help()
	end, { silent = true, noremap = true, buffer = bufnr, desc = "Lsp: signature help" })
	vim.keymap.set(
		"n",
		"<Leader>ca",
		vim.lsp.buf.code_action,

		{ silent = true, noremap = true, buffer = bufnr, desc = "Lsp: code action" }
	)
	vim.keymap.set(
		"n",
		"<Leader>rn",
		vim.lsp.buf.rename,
		{ silent = true, noremap = true, buffer = bufnr, desc = "Lsp: rename" }
	)
end

function M.telescope()
	local telescope = require("telescope")
	local telescope_builtin = require("telescope.builtin")

	vim.keymap.set(
		"n",
		"<Leader>fk",
		telescope_builtin.keymaps,
		{ silent = true, noremap = true, desc = "Telescope: keymaps" }
	)
	vim.keymap.set(
		"n",
		"<Leader>fb",
		telescope_builtin.buffers,
		{ silent = true, noremap = true, desc = "Telescope: buffers" }
	)
	vim.keymap.set(
		"n",
		"<Leader>fq",
		telescope_builtin.quickfixhistory,
		{ silent = true, noremap = true, desc = "Telescope: quickfix lists" }
	)
	vim.keymap.set(
		"n",
		"<Leader>ff",
		telescope_builtin.find_files,
		{ silent = true, noremap = true, desc = "Telescope: find files" }
	)
	vim.keymap.set("n", "<Leader>fm", function()
		telescope_builtin.marks()
	end, { silent = true, noremap = true, desc = "Telescope: find marks" })
	vim.keymap.set(
		"n",
		"<Leader>fg",
		telescope.extensions.live_grep_args.live_grep_args,
		{ silent = true, noremap = true, desc = "Telescope: live grep" }
	)
	-- Search neovim config. We get the path to the init.lua file, resolve resolve it (to get the real file if it is a symlink), and remove the /init.lua suffix to get the directory path.
	vim.keymap.set("n", "<Leader>fc", function()
		telescope_builtin.find_files({
			cwd = string.gsub(vim.fn.resolve(vim.fn.stdpath("config") .. "/init.lua"), "/init.lua", ""),
		})
	end, { silent = true, noremap = true, desc = "Telescope: find files in neovim config" })
	vim.keymap.set("n", "<Leader>fn", function()
		local notes_dir = os.getenv("HOME") .. "/repos/notes/"
		telescope_builtin.find_files({
			cwd = vim.fn.resolve(notes_dir),
		})
	end, { silent = true, noremap = true, desc = "Telescope: find files in notes" })
end

function M.oil()
	local oil = require("oil")

	vim.keymap.set("n", "-", function()
		oil.open_float()
	end, { noremap = true, silent = true, desc = "Oil: open parent directory" })
	vim.keymap.set("n", "_", function()
		oil.open_float(vim.fn.getcwd())
	end, { noremap = true, silent = true, desc = "Oil: open current working directory" })
end

function M.dap()
	local dap = require("dap")
	local dap_utils = require("utils.dap")

	vim.keymap.set(
		"n",
		"<Leader>bp",
		dap.toggle_breakpoint,
		{ silent = true, noremap = true, desc = "Dap: toggle breakpoint" }
	)
	vim.keymap.set("n", "<Leader>dq", dap.terminate, { silent = true, noremap = true, desc = "Dap: terminate session" })
	vim.keymap.set(
		"n",
		"<Leader>db",
		dap_utils.debug_with_repl,
		{ silent = true, noremap = true, desc = "Dap: start debugging" }
	)
	vim.keymap.set("n", "<Leader>dc", dap.continue, { silent = true, noremap = true, desc = "Dap: continue" })
	vim.keymap.set("n", "<Leader>dr", dap.restart, { silent = true, noremap = true, desc = "Dap: restart" })
	vim.keymap.set("n", "<Leader>so", dap.step_over, { silent = true, noremap = true, desc = "Dap: step over" })
	vim.keymap.set("n", "<Leader>si", dap.step_into, { silent = true, noremap = true, desc = "Dap: step into" })
	vim.keymap.set("n", "<Leader>su", dap.step_out, { silent = true, noremap = true, desc = "Dap: step out of" })
	vim.keymap.set("n", "<Leader>bl", function()
		dap.list_breakpoints()
	end, { silent = true, noremap = true, desc = "Dap: add breakpoints to quickfix list" })
	vim.keymap.set("n", "<Leader>ro", function()
		dap.repl.open({}, "vsplit new")
	end, { silent = true, noremap = true, desc = "Dap: open the repl" })
	vim.keymap.set(
		"n",
		"<Leader>bc",
		dap.clear_breakpoints,
		{ silent = true, noremap = true, desc = "Dap: clear breakpoints" }
	)
end

function M.diffview()
	local diffview = require("diffview")
	local actions = require("diffview.actions")

	vim.keymap.set("n", "<Leader>gs", diffview.open, { silent = true, noremap = true, desc = "Diffview: open" })
	vim.keymap.set(
		"n",
		"<Leader>gr",
		actions.refresh_files,
		{ silent = true, noremap = true, desc = "Diffview: refresh" }
	)
end

function M.neotest()
	local neotest = require("neotest")
	local dap_utils = require("utils.dap")

	vim.keymap.set("n", "<Leader>rt", function()
		neotest.run.run()
	end, { silent = true, noremap = true, desc = "Neotest: run closest test" })
	vim.keymap.set(
		"n",
		"<Leader>dt",
		dap_utils.debug_closest_test_with_repl,
		{ silent = true, noremap = true, desc = "Neotest: debug closest test" }
	)
end

function M.gitsigns(buffer)
	local gitsigns = require("gitsigns")

	vim.keymap.set("n", "]h", function()
		if vim.wo.diff then
			return "]h"
		end
		vim.schedule(function()
			gitsigns.next_hunk()
			gitsigns.preview_hunk()
		end)
		return "<Ignore>"
	end, { expr = true, buffer = buffer, desc = "Gitsigns: next hunk" })
	vim.keymap.set("n", "[h", function()
		if vim.wo.diff then
			return "[h"
		end
		vim.schedule(function()
			gitsigns.prev_hunk()
			gitsigns.preview_hunk()
		end)
		return "<Ignore>"
	end, { expr = true, buffer = buffer, desc = "Gitsigns: previous hunk" })
	vim.keymap.set(
		"n",
		"<Leader>hs",
		gitsigns.stage_hunk,
		{ silent = true, noremap = true, buffer = buffer, desc = "Gitsigns: stage hunk" }
	)
	vim.keymap.set(
		"n",
		"<Leader>hr",
		gitsigns.reset_hunk,
		{ silent = true, noremap = true, buffer = buffer, desc = "Gitsigns: reset hunk" }
	)
	vim.keymap.set("v", "<Leader>hs", function()
		gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
	end, { silent = true, noremap = true, buffer = buffer, desc = "Gitsigns: stage hunk" })
	vim.keymap.set("v", "<Leader>hr", function()
		gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
	end, { silent = true, noremap = true, buffer = buffer, desc = "Gitsigns: reset hunk" })
	vim.keymap.set(
		"n",
		"<Leader>hu",
		gitsigns.undo_stage_hunk,
		{ silent = true, noremap = true, buffer = buffer, desc = "Gitsigns: undo stage hunk" }
	)
	vim.keymap.set("n", "<Leader>gb", function()
		gitsigns.blame_line({ full = true })
	end, { silent = true, noremap = true, buffer = buffer, desc = "Gitsigns: line blame" })
end

function M.vim_markdown_toc()
	vim.keymap.set(
		{ "n", "v" },
		"<Leader>tc",
		":GenTocGFM<CR>",
		{ buffer = true, noremap = true, silent = true, desc = "Vim-markdown-toc: generate table of contents" }
	)
end

function M.markdown_preview()
	vim.keymap.set(
		{ "n", "v" },
		"<Leader>mo",
		":MarkdownPreview<CR>",
		{ buffer = true, noremap = true, silent = true, desc = "MarkdownPreview: open" }
	)
	vim.keymap.set(
		{ "n", "v" },
		"<Leader>mc",
		":MarkdownPreviewStop<CR>",
		{ buffer = true, noremap = true, silent = true, desc = "MarkdownPreview: close" }
	)
end

function M.typescript()
	vim.keymap.set("n", "<Leader>1", "o(x)<Space>=><Space>x,<Esc>", {
		buffer = true,
		noremap = true,
		silent = true,
		desc = "Typescript: insert identity function on new line",
	})
	vim.keymap.set("n", "<Leader>2", "a,(x)<Space>=><Space>x<Esc>", {
		buffer = true,
		noremap = true,
		silent = true,
		desc = "Typescript: insert identity function on current line",
	})
end

return M
