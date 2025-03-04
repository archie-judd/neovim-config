local config = require("codecompanion.config")
local xml2lua = require("xml2lua")

return {
	name = "clipboard",
	cmds = {
		function(self, input)
			vim.fn.setreg(input.register or '"', input.text)
			return {
				status = "success",
				msg = input.text_to_copy,
			}
		end,
	},
	schema = {
		{
			tool = {
				_attr = { name = "clipboard" },
				action = {
					_attr = { type = "copy" },
					text = "<![CDATA[text_to_copy]]>",
					register = "<![CDATA[register]]>",
				},
			},
		},
	},
	system_prompt = function(schema)
		return string.format(
			[[### Clipboard tool
		1. **Purpose**: Allows you to copy your response to the clipboard register. If no register is specified, 
		use '"'.
		2. **Usage**: To call this tool, you **must** return an XML block inside triple backticks, following the 
		exact structure below.
		3. **Important**:
			- The XML **must** start with `<tool name="clipboard">`.
			- The `<action>` tag **must** contain a `type="copy"` attribute.
			- The `<text>` tag and the `<register>` tag **must** be inside `<action>`.
			- Do **not** modify the structure.
			- **Example of correct XML format:**

		```xml
		%s
		```]],
			xml2lua.toXml({ tools = { schema[1] } })
		)
	end,
	output = {
		success = function(self, cmd, output)
			self.chat:add_buf_message({
				role = config.constants.USER_ROLE,
				content = string.format(
					"[Clipboard Tool] Text copied successfully to the '%s' register: '%s'",
					cmd.register,
					cmd.text
				),
			})
		end,
		error = function(self, cmd, error)
			config.chat:add_buf_message({
				role = config.constants.USER_ROLE,
				content = string.format("[Clipboard Tool] encountered an error!\n\nError: '%s'", error),
			})
		end,
	},
}
