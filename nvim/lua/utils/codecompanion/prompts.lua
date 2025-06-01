M.edit_current_buffer = {
	strategy = "chat",
	description = "Edit the current buffer",
	prompts = {
		{
			role = "system",
			[[You are an experienced developer. You will be requested to make some changes to a provided buffer. Keep 
your responses concise and to the point. Don't include next-step suggestions. When the user asks you a question about 
the buffer, edit it with your suggestions using your editor tool unless the user asks you to do otherwise. If you are 
asked to edit a function, make sure to include any decorators in the existing function when making your edits.]],
		},
		{
			role = "user",
			content = "@editor make the following changes to #buffer{watch}:  ",
		},
	},
	opts = {
		modes = { "n" },
		is_slash_cmd = true,
		short_name = "ecb",
		auto_submit = false,
		index = 1,
		stop_context_insertion = true,
		user_prompt = false,
	},
}

M.suggest_commits = {
	strategy = "chat",
	description = "Suggest a commit sequence given a git diff",
	prompts = {
		{
			role = "system",
			content = function()
				return [[
Suggest a sequence of commits that make sense with the following considerations:

1. Each commit should be 'atomic' - ie, should contain a single-responsibility, self-contained and independent group of 
changes.
2. Commits should be listed in the order in which they should be applied.
4. List the files that were changed in each group. If a file was changed in multiple groups, for each group list the 
diff lines, and ensure there is no intersection between the groups.
5. **IMPORTANT** make sense to format the response using the following rules:
- Format your response with markdown.
- Each commmit should have it's own section with a header very concisely describing the commit (< 12 words).
- Under each header should be a description and an inline code block with the suggested commit message.
- The the diff files and lines should be formatted as code blocks.

]]
			end,
		},
		{
			role = "user",
			content = function()
				vim.g.codecompanion_auto_tool_mode = true
				return [[
@lua_cmd_runner Here is the git diff: #diff. 

Suggest a sequence of commits that make sense given the diff.
]]
			end,
		},
	},
	opts = {
		modes = { "n" },
		is_slash_cmd = true,
		short_name = "sc",
		auto_submit = true,
		index = 2,
		stop_context_insertion = true,
		user_prompt = false,
	},
}

return M
