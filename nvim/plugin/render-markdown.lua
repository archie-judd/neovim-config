local render_markdown = require("render-markdown")

local function config()
	render_markdown.setup({
		file_types = { "markdown", "gitcommit", "codecompanion" },
	})
end

config()
