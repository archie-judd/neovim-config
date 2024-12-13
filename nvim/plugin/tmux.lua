local tmux = require("tmux")
local config = function()
	tmux.setup({
		copy_sync = { enable = false },
		resize = {
			enable_default_keybindings = true,
			resize_step_x = 5,
			resize_step_y = 5,
		},
	})
end

config()
