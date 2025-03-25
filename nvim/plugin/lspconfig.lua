local autocommands = require("config.autocommands")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local lspconfig = require("lspconfig")
local neodev = require("neodev")
local utils = require("utils.lsp")

local config = function()
	local capabilities = cmp_nvim_lsp.default_capabilities()

	neodev.setup({})
	autocommands.lspconfig()
	lspconfig.ts_ls.setup({
		capabilities = capabilities,
		commands = {
			OrganizeTSImports = {
				utils.tsserver_organize_imports,
				description = "Organize Typescipt imports for current file",
			},
		},
	})
	lspconfig.pyright.setup({ capabilities = capabilities })
	lspconfig.pylsp.setup({
		settings = {
			capabilities = capabilities,
			pylsp = {
				plugins = {
					mypy = { enabled = true, live_mode = true, dmypy = true },
					pylint = { enabled = true },
					pyflakes = { enabled = false },
					pycodestyle = { enabled = false },
				},
			},
		},
	})
	lspconfig.mypy.setup({ capabilities = capabilities })
	lspconfig.lua_ls.setup({ capabilities = capabilities })
	lspconfig.eslint.setup({ capabilities = capabilities })
	lspconfig.marksman.setup({ capabilities = capabilities })
	lspconfig.bashls.setup({ capabilities = capabilities })
	lspconfig.nixd.setup({ capabilities = capabilities })
	lspconfig.hls.setup({ capabilities = capabilities })
	lspconfig.sqlls.setup({ capabilities = capabilities })
	lspconfig.yamlls.setup({ capabilities = capabilities })
	lspconfig.emmet_language_server.setup({ capabilities = capabilities })

	vim.lsp.handlers["textDocument/publishDiagnostics"] =
		vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false })

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		border = "rounded",
		silent = true,
		focusable = true,
		max_height = 15,
		max_width = 60,
	})

	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
		border = "rounded",
		silent = true,
		focusable = true,
		max_height = 15,
		max_width = 65,
	})
end

config()
