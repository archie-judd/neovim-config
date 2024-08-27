local config = function()
	local autocommands = require("config.autocommands")
	local cmp_nvim_lsp = require("cmp_nvim_lsp")
	local lspconfig = require("lspconfig")
	local neodev = require("neodev")

	local capabilities = cmp_nvim_lsp.default_capabilities()

	neodev.setup({})
	autocommands.lspconfig()

	local function tsserver_organize_imports()
		local params = {
			command = "_typescript.organizeImports",
			arguments = { vim.api.nvim_buf_get_name(0) },
			title = "",
		}
		vim.lsp.buf.execute_command(params)
	end

	lspconfig.tsserver.setup({
		capabilities = capabilities,
		commands = {
			OrganizeImports = {
				tsserver_organize_imports,
				description = "Organize Imports",
			},
		},
	})
	lspconfig.pyright.setup({ capabilities = capabilities })
	lspconfig.lua_ls.setup({ capabilities = capabilities })
	lspconfig.eslint.setup({ capabilities = capabilities })
	lspconfig.marksman.setup({ capabilities = capabilities })
	lspconfig.bashls.setup({ capabilities = capabilities })
	lspconfig.nixd.setup({ capabilities = capabilities })
	lspconfig.hls.setup({ capabilities = capabilities })
	lspconfig.sqlls.setup({ capabilities = capabilities })

	vim.lsp.handlers["textDocument/publishDiagnostics"] =
		vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false })

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		border = "rounded",
		silent = true,
		focusable = false,
		max_height = 15,
		max_width = 60,
	})

	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
		border = "rounded",
		silent = true,
		focusable = false,
		max_height = 15,
		max_width = 65,
	})
end

config()
