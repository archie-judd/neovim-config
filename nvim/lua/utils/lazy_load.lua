local M = {}

local loaded = {}

---Create a lazy-loading keymap that loads a plugin on first use
---@param keys string The key mapping (e.g., "<LocalLeader>c")
---@param config_fn function The function to call to configure the plugin
---@param keymap_opts vim.keymap.set.Opts | nil
---@param plugin_name string Unique name for the plugin (for tracking loaded state)
function M.lazy_keymap(modes, keys, config_fn, keymap_opts, plugin_name)
	vim.keymap.set(modes, keys, function()
		if not loaded[plugin_name] then
			config_fn()
			loaded[plugin_name] = true
		end
		local expanded_keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
		vim.api.nvim_feedkeys(expanded_keys, "m", false)
	end, keymap_opts)
end

return M
