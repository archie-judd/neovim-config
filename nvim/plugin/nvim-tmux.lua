local tmux = require("tmux")
local config = function()
	tmux.setup({
		copy_sync = { enable = false },
	})
end

config()
