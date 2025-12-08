local config = function()
	local tmux = require("tmux")

	tmux.setup({
		copy_sync = { enable = false },
		resize = {
			enable_default_keybindings = true,
			resize_step_x = 5,
			resize_step_y = 5,
		},
	})
end

vim.defer_fn(config, 0)
