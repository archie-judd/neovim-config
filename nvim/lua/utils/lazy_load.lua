local M = {}

local loaded = {}

---@param config_fn function
---@param plugin_name string
---@param modes string | string[]
---@param lhses string[] | string
function M.load_plugin_on_keymap(config_fn, plugin_name, modes, lhses)
	---@type string[]
	local keys_list = type(lhses) == "table" and lhses or { lhses }

	for _, lhs in ipairs(keys_list) do
		vim.keymap.set(modes, lhs, function()
			if not loaded[plugin_name] then
				config_fn()
				loaded[plugin_name] = true
			end
			local keys = vim.api.nvim_replace_termcodes(lhs, true, false, true)
			local mode = vim.api.nvim_get_mode().mode
			vim.api.nvim_feedkeys(keys, mode, false)
		end, { silent = true, desc = "Lazy load " .. plugin_name })
	end
end

---@param config_fn function
---@param plugin_name string
---@param event any
function M.load_plugin_on_event(config_fn, plugin_name, event)
	local group = vim.api.nvim_create_augroup("LazyLoad_" .. plugin_name, { clear = true })

	vim.api.nvim_create_autocmd(
		event,
		vim.tbl_extend("force", {}, {
			group = group,
			once = true, -- Automatically remove after first trigger
			callback = function()
				if not loaded[plugin_name] then
					config_fn()
					loaded[plugin_name] = true
				end

				-- Re-trigger the event so the plugin's own autocommands can respond
				vim.api.nvim_exec_autocmds(event, {
					modeline = false,
				})
			end,
		})
	)
end

return M
