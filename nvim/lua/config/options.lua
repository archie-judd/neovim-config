local osc52 = require("vim.ui.clipboard.osc52")

-- Color-scheme
vim.cmd.colorscheme("catppuccin-mocha")

-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.splitright = true
vim.opt.pumheight = 10
vim.opt.completeopt = "menuone,noinsert,preview"
vim.opt.shortmess = "ctF" -- 'c' means 'don't show ins-completion mode messages', 't' means truncate file message when opening a file, 'F' means don't show file edit messages upon opening
vim.opt.laststatus = 3 -- only one statusline
vim.opt.backupcopy = "yes" -- when writing a file, make a copy of the original file in the backup location, instead of moving it (which can interfere with file watchers)
vim.opt.shell = vim.env.SHELL
vim.opt.shellcmdflag = "-c"

-- Clipboard
vim.g.clipboard = { -- OSC52 clipboard
	name = "OSC 52",
	copy = {
		["+"] = osc52.copy("+"),
		["*"] = osc52.copy("*"),
	},
	paste = {
		["+"] = osc52.paste("+"),
		["*"] = osc52.paste("*"),
	},
}

-- Diagnostics
vim.diagnostic.config({ float = { border = "rounded" } })
