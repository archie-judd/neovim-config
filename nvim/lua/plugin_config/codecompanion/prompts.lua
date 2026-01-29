local M = {}

M.edit_current_buffer = {
	strategy = "chat",
	description = "Edit the current buffer",
	prompts = {
		{
			role = "system",
			content = [[You are an experienced developer. You will be requested to make some changes to a provided buffer. Keep 
your responses concise and to the point. Don't include next-step suggestions. When the user asks you a question about 
the buffer, edit it with your suggestions using your editor tool unless the user asks you to do otherwise.]],
		},
		{
			role = "user",
			content = "Here is the current buffer: #{buffer}\n\nUsing your @{insert_edit_into_file} tool, make the following change(s):\n\n",
		},
	},
	opts = {
		modes = { "n" },
		is_slash_cmd = true,
		short_name = "edit_buffer",
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
Suggest a sequence of commits that make sense. Try to suggest the smallest number of commits with the following considerations:

1. Commits should follow the Conventional Commit Specification.
2. Commits should be listed in the order in which they should be applied.
3. Under each commit, list the files that were changed in that commit.
4. **IMPORTANT** make sense to format the response using the following rules:
- Format your response with markdown.
- Commits should appear in block-quotes under headered sections.
]]
			end,
		},
		{
			role = "user",
			content = function()
				vim.g.codecompanion_auto_tool_mode = true
				return [[
Here is the git diff: #{staged_diff} 

Suggest a sequence of commits that make sense given the diff.
]]
			end,
		},
	},
	opts = {
		modes = { "n" },
		is_slash_cmd = true,
		short_name = "commits",
		auto_submit = true,
		index = 2,
		stop_context_insertion = true,
		user_prompt = false,
	},
}

return M
