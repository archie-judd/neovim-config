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
		[[
    ## Lua Command Runner Tool (`lua_cmd_runner`) 

    ### CONTEXT:
    - Execute safe, validated lua commands on the user's system when explicitly requested.

    ### OBJECTIVE:
    - Execute a lua command in the user's environment when requested.		

    ### CONSIDERATIONS
    - **Safety First:** Ensure every command is safe and validated.
    - **User Environment Awareness:**
    - **Neovim Version**: %s
    - **User Oversight:** The user retains full control with an approval mechanism before execution.
    - **Extensibility:** If environment details aren’t available (e.g., language version details), output the command 
    first along with a request for more information.
    - Only invoke the command runner when the user specifically asks.
    - Use this tool strictly for command execution; file operations must be handled with the 
    designated Files Tool.
    ]],
		vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
	),

	handlers = {
		setup = function(self, agent)
			local cmd = vim.trim(self.args.cmd)
			local lua_cmd = function(self)
				local chunk, load_err = load(cmd)
				if not chunk then
					return { status = "error", data = "Syntax error: " .. tostring(load_err) }
				end
				
				local success, res = pcall(chunk)
				local status = success and "success" or "error"
				return { status = status, data = res }
			end
			table.insert(self.cmds, lua_cmd)
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
			local message = string.format("**Lua Cmd Runner Tool**: Ran the following command:\n\n%s", self.args.cmd)
			
			if not stdout or vim.tbl_isempty(stdout) then
				message = string.format("%s\n\nNo output was returned.", message)
			else
				local output = stdout[1]
				local formatted_output
				if output == nil then
					formatted_output = "nil"
				elseif type(output) == "table" then
					formatted_output = "```lua\n" .. vim.inspect(output) .. "\n```"
				else
					formatted_output = tostring(output)
				end
				message = string.format("%s\n\nOutput:\n%s", message, formatted_output)
			end
			agent.chat:add_tool_output(self, message)
		end,
		error = function(self, agent, cmd, stderr, stdout)
			local error_msg = "An error occurred"
			if stderr and not vim.tbl_isempty(stderr) then
				error_msg = error_msg .. ": " .. tostring(stderr[1])
			end
			agent.chat:add_tool_output(self, error_msg)
			return vim.notify(error_msg, vim.log.levels.ERROR)
		end,
	},
}
