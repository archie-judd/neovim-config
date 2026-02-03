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

return M
