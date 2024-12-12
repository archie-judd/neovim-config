local tmux = require("tmux")
local config = function()
	tmux.setup({
		copy_sync = { enable = false },
		resize = {
			enable_default_keybindings = true,
			resize_step_x = 10,
			resize_step_y = 10,
		},
	})
end

config()
