local M = {}

local loaded = {}
local configs = {}

function M.ensure_loaded(plugin_name)
	if not loaded[plugin_name] then
		if configs[plugin_name] then
			configs[plugin_name]()
			loaded[plugin_name] = true
		else
			vim.notify("No config registered for plugin: " .. plugin_name, vim.log.levels.ERROR)
		end
	end
end

---@param config_fn function
---@param plugin_name string
---@param keymaps table<string, string[]>
function M.load_plugin_on_keymaps(config_fn, plugin_name, keymaps)
	configs[plugin_name] = config_fn
	local expanded_keys = {}
	for mode, keys in pairs(keymaps) do
		expanded_keys[mode] = {}
		for _, key in ipairs(keys) do
			table.insert(expanded_keys[mode], vim.api.nvim_replace_termcodes(key, true, true, true))
		end
	end
	---@type string[]
	for mode, keys in pairs(keymaps) do
		for idx, key in ipairs(keys) do
			vim.keymap.set(mode, key, function()
				for del_mode, del_keys in pairs(expanded_keys) do
					for _, del_key in ipairs(del_keys) do
						vim.keymap.del(del_mode, del_key)
					end
				end
				if not loaded[plugin_name] then
					config_fn()
					loaded[plugin_name] = true
				end
				local expanded_key = expanded_keys[mode][idx]
				vim.api.nvim_feedkeys(expanded_key, "m", false)
			end, { silent = true, desc = "Lazy load " .. plugin_name })
		end
	end
end

---@param config_fn function
---@param plugin_name string
---@param event string | string[]
---@param pattern string | string[] | nil
function M.load_plugin_on_event(config_fn, plugin_name, event, pattern)
	configs[plugin_name] = config_fn
	local group = vim.api.nvim_create_augroup("LazyLoad" .. plugin_name, { clear = true })

	vim.api.nvim_create_autocmd(event, {
		pattern = pattern,
		group = group,
		once = true,
		callback = function()
			if not loaded[plugin_name] then
				config_fn()
				loaded[plugin_name] = true
			end
			vim.api.nvim_exec_autocmds(event, {
				modeline = false,
			})
		end,
	})
end

return M
