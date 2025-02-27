local config = require("codecompanion.config")
local xml2lua = require("xml2lua")

return {
	name = "lua_cmd_runner",
	cmds = {},
	schema = {
		{
			tool = {
				_attr = { name = "lua_cmd_runner" },
				action = {
					{
						command = "<![CDATA[vim.print('hello')]]>",
						force = false,
					},
				},
			},
		},
	},
	system_prompt = function(schema)
		return string.format(
			[[## Lua Command Runner Tool (`lua_cmd_runner`) – Enhanced Guidelines

### Purpose:
- Execute safe, validated lua commands on the user's system when explicitly requested.

### When to Use:
- Only invoke the command runner when the user specifically asks.
- Use this tool strictly for command execution; file operations must be handled with the designated Files Tool.

### Execution Format:
- Always return an XML markdown code block.
- Each command  should:
  - Be wrapped in a CDATA section to protect special characters.
  - Follow the XML schema exactly. Do not include multiple commands in a single action. If you are asked to run multiple lua commands, combine them into a single command. 
  - If the user has specified to force the command, set force to true, otherwise set it to false. Setting force to true will bypass the user approval mechanism.

```xml
%s
```

### Key Considerations
- **Safety First:** Ensure every command is safe and validated.
- **User Environment Awareness:**
  - **Neovim Version**: %s

- **User Oversight:** The user retains full control with an approval mechanism before execution.
- **Extensibility:** If environment details aren’t available (e.g., language version details), output the command first along with a request for more information.

### Reminder
- Minimize explanations and focus on returning precise XML blocks with CDATA-wrapped commands.
- Follow this structure each time to ensure consistency and reliability.]],
			xml2lua.toXml({ tools = { schema[1] } }),
			vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
		)
	end,
	handlers = {
		setup = function(self)
			local action = self.tool.request.action
			local lua_cmd = function(self, input)
				local success, res = pcall(load(action.command))
				local status = nil
				if success then
					status = "success"
				else
					status = "error"
				end
				return { status = status, msg = nil }
			end
			table.insert(self.tool.cmds, lua_cmd)
		end,
		approved = function(self, cmd)
			local force = cmd.force == "true" or false
			if vim.g.codecompanion_auto_tool_mode or force then
				vim.notify("[Lua Cmd Runner Tool] Auto-approved running the command", vim.log.levels.INFO)
				return true
			end

			local cmd_concat = table.concat(cmd.cmd or cmd, " ")

			local msg = "Run command: `" .. cmd_concat .. "`?"
			local ok, choice = pcall(vim.fn.confirm, msg, "No\nYes")
			if not ok or choice ~= 2 then
				vim.notify("[Lua Cmd Runner Tool] Rejected running the command", vim.log.levels.INFO)
				return false
			end

			return true
		end,
	},
	output = {
		rejected = function(self, action)
			self.chat:add_buf_message({
				role = config.constants.USER_ROLE,
				content = string.format("I chose not to run %s", action.command),
			})
		end,
		error = function(self, action, stderr)
			self.chat:add_buf_message({
				role = config.constants.USER_ROLE,
				content = string.format("There was an error running %s", action.command),
			})
		end,
		success = function(self, action)
			self.chat:add_buf_message({
				role = config.constants.USER_ROLE,
				content = string.format("Success running command %s", action.command),
			})
		end,
	},
}
