local config = function()
	require("copilot").setup({
		suggestion = { enabled = false },
		panel = { enabled = false },
	})
end

config()
