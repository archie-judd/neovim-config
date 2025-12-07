local function config()
	local render_markdown = require("render-markdown")

	render_markdown.setup({
		file_types = { "markdown", "gitcommit", "codecompanion" },
	})
end

config()
