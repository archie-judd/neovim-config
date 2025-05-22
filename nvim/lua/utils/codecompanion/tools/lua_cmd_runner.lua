return {
	name = "lua_cmd_runner",
	cmds = {},
	schema = {
		type = "function",
		["function"] = {
			name = "lua_cmd_runner",
			description = "Run a lua command in the user's environment",
			parameters = {
				type = "object",
				properties = {
					cmd = { type = "string", description = "The lua command(s) to run, separated by ';'" },
				},
				required = { "cmd" },
				additionalProperties = false,
			},
			strict = true,
		},
	},
	system_prompt = string.format(
		[[## Lua Command Runner Tool (`lua_cmd_runner`) 

			### CONTEXT:
			- Execute safe, validated lua commands on the user's system when explicitly requested.

			### OBJECTIVE:
      - Execute lua command(s) in the user's environment when requested.
			
			### CONSIDERATIONS
      - Where multiple commands are provided, they will be seperated by a `;` and executed in order.
			- **Safety First:** Ensure every command is safe and validated.
			- **User Environment Awareness:**
			- **Neovim Version**: %s
			- **User Oversight:** The user retains full control with an approval mechanism before execution.
			- **Extensibility:** If environment details aren’t available (e.g., language version details), 
			output the command first along with a request for more information.
			- Only invoke the command runner when the user specifically asks.
			- Use this tool strictly for command execution; file operations must be handled with the 
			designated Files Tool.
      ]],
		vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
	),

	handlers = {
		setup = function(self, agent)
			local args = self.args
			for _, cmd in ipairs(vim.split(args.cmd, ";")) do
				cmd = vim.trim(cmd)
				if cmd == "" then
					return
				end
				local lua_cmd = function(self)
					local success, res = pcall(load(cmd))
					local status = nil
					if success then
						status = "success"
					else
						status = "error"
					end
					return { status = status, data = res }
				end
				table.insert(self.cmds, lua_cmd)
			end
		end,
	},

	output = {
		prompt = function(self, agent)
			return string.format("Perform the lua command `%s`?", self.args.cmd)
		end,
		rejected = function(self, agent, cmd)
			agent.chat:add_tool_output(self, "The user declined to run the cmd")
		end,
		success = function(self, agent, cmd, stdout)
			local message = nil
			if stdout and vim.tbl_isempty(stdout) then
				message = string.format(
					[[The lua_cmd_runner tool ran the following commands, but there was no output: %s There was no output from the lua_cmd_runner tool]],
					cmd.cmd
				)
			else
				local output = vim.iter(stdout[#stdout]):flatten():join("\n")
				message = string.format(
					[[**Cmd Runner Tool**: The output from the command `%s` was:

  ```txt
  %s
  ```]],
					table.concat(cmd.cmd, " "),
					output
				)
			end
			self.chat:add_tool_output(self, message)
		end,
		error = function(self, agent, cmd, stderr, stdout)
			return vim.notify("An error occurred", vim.log.levels.ERROR)
		end,
	},
}
