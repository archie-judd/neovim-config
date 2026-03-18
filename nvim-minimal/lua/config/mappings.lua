local M = {}

function M.core()
	local core_utils = require("lib.core")
	-- Set mapleader
	vim.g.mapleader = ";"

	-- Close floating windows
	vim.keymap.set({ "n" }, "<C-q>", function()
		core_utils.close_active_or_topmost_floating_window(false)
	end, { silent = true, noremap = true, desc = "Windows: close active or topmost floating window" })

	vim.api.nvim_set_keymap(
		"t",
		"<Esc>",
		[[<C-\><C-n>]],
		{ noremap = true, silent = true, desc = "Terminal: exit terminal mode" }
	)

	-- Move to the next or previous conflict
	vim.keymap.set("n", "]x", core_utils.next_conflict, { desc = "Next merge conflict" })
	vim.keymap.set("n", "[x", core_utils.prev_conflict, { desc = "Previous merge conflict" })

	-- Delete unneeded default diagnostics mappings
	vim.api.nvim_del_keymap("n", "<C-w>d")
	vim.api.nvim_del_keymap("n", "<C-w><C-d>")

	-- Move to next / previous windows
	vim.keymap.set(
		{ "n", "i" },
		"<C-w>",
		core_utils.switch_windows,
		{ silent = true, noremap = true, desc = "Windows: move to the next window" }
	)
	vim.keymap.set({ "n", "i" }, "<C-S-w>", function()
		core_utils.switch_windows({ reverse = true })
	end, { silent = true, noremap = true, desc = "Windows: move to the previous window" })

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

	-- Keep cursor central when jumping from search results
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

	-- Inserting new lines
	vim.keymap.set("n", "<Leader>o", "jO<Esc>k", { silent = true, noremap = true, desc = "Insert line: below" })
	vim.keymap.set("n", "<Leader>O", "ko<Esc>j", { silent = true, noremap = true, desc = "Insert line: above" })
end

function M.telescope()
	local telescope_builtin = require("telescope.builtin")
	local telescope = require("telescope")

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
		"<Leader>fr",
		telescope_builtin.registers,
		{ silent = true, noremap = true, desc = "Telescope: registers" }
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
	vim.keymap.set(
		"n",
		"<Leader>fm",
		telescope_builtin.marks,
		{ silent = true, noremap = true, desc = "Telescope: find marks" }
	)
	vim.keymap.set(
		"n",
		"<Leader>fg",
		telescope.extensions.live_grep_args.live_grep_args,
		{ silent = true, noremap = true, desc = "Telescope: live grep" }
	)
end

function M.oil()
	local oil = require("oil")

	vim.keymap.set("n", "-", oil.open_float, { noremap = true, silent = true, desc = "Oil: open parent directory" })
	vim.keymap.set("n", "_", function()
		oil.open_float(vim.fn.getcwd())
	end, { noremap = true, silent = true, desc = "Oil: open current working directory" })
end

function M.quickfix()
	vim.keymap.set("n", "<C-q>", function()
		vim.api.nvim_buf_delete(0, { force = true })
	end, {
		buffer = true,
		silent = true,
		noremap = true,
		desc = "Quickfix: close",
	})
end

function M.terminal()
	local terminal = require("lib.plugin.terminal")

	vim.keymap.set("n", "<leader>tt", terminal.open, { noremap = true, silent = true, desc = "Terminal: open" })
end

return M
