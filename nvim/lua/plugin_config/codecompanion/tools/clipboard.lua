return {
	name = "clipboard",
	cmds = {
		function(self, args, input)
			local register = args.register or '"'
			vim.fn.setreg(register, args.text_to_copy)
			return {
				status = "success",
				data = string.format("Copied '%s' to register %s", args.text_to_copy, register),
			}
		end,
	},
	schema = {
		type = "function",
		["function"] = {
			name = "clipboard",
			description = "Copy text to the a given neovim register",
			parameters = {
				type = "object",
				properties = {
					text_to_copy = {
						type = "string",
						description = "The text to copy to the clipboard",
					},
					register = {
						type = "string",
						description = "The clipboard register to copy to",
					},
				},
				required = {
					"text_to_copy",
				},
				additionalProperties = false,
			},
			strict = true,
		},
	},
	system_prompt = [[### Clipboard tool ('clipboard')

	  ### CONTEXT
	  - You have access to a clipboard tool running within CodeCompanion, in Neovim.
	  - You can use it to copy text to any register in Neovim.

	  ### OBJECTIVE
	  - Copy a text to a given register in Neovim when requested.

	  ### RESPONSE
	  - Always use the structure above for consistency.
	]],
	handlers = {
		setup = function(self, agent) end,
		on_exit = function(self, agent) end,
	},
	output = {
		success = function(self, agent, cmd, stdout)
			local chat = agent.chat
			return chat:add_tool_output(self, tostring(stdout[1]))
		end,
		error = function(self, agent, cmd, stderr, stdout)
			return vim.notify("An error occurred", vim.log.levels.ERROR)
		end,
	},
}
