local DAP_LEADER = ","

local config = function()
	local autocommands = require("config.autocommands")
	local dap = require("dap")
	local dap_utils = require("plugin_config.dap.utils")
	local dap_python = require("plugin_config.dap.python")
	local dap_pwa_node = require("plugin_config.dap.pwa_node")
	local mappings = require("config.mappings")
	local telescope = require("telescope")

	vim.g.maplocalleader = DAP_LEADER

	-- set defaults
	dap.defaults.fallback.exception_breakpoints = "default"
	dap.defaults.fallback.terminal_win_cmd = dap_utils.open_terminal
	dap.defaults.fallback.switchbuf = "usevisible,useopen,uselast"

	dap.listeners.after.event_stopped["notify"] = function()
		vim.notify("Debugger paused", vim.log.levels.WARN)
	end

	dap_python.setup()
	dap_pwa_node.setup()
	mappings.dap()
	autocommands.dap()
	telescope.load_extension("dap")
end

local function load_on_keymap()
	local lazy_load_util = require("utils.lazy_load")
	vim.g.maplocalleader = DAP_LEADER
	lazy_load_util.load_plugin_on_keymaps(config, "dap", { n = { "<LocalLeader>d", "<LocalLeader>b" } })
end

load_on_keymap()
