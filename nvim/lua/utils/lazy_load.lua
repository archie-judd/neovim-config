local M = {}

local loaded = {}

---Create a lazy-loading keymap that loads a plugin on first use
---@param plugin_name string Unique name for the plugin (for tracking loaded state)
---@param keys string The key mapping (e.g., "<LocalLeader>c")
---@param keymap_opts vim.keymap.set.Opts | nil
---@param config_fn function The function to call to configure the plugin
---@param action_fn function | nil An optional function to execute after loading the plugin
function M.load_plugin_on_keymap(plugin_name, modes, keys, keymap_opts, config_fn, action_fn)
	vim.keymap.set(modes, keys, function()
		if not loaded[plugin_name] then
			config_fn()
			loaded[plugin_name] = true
		end
		if action_fn then
			action_fn()
		end
	end, keymap_opts)
end

return M
