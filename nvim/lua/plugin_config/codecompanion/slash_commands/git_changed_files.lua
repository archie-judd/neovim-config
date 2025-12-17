local Path = require("plenary.path")

local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local chat_helpers = require("codecompanion.strategies.chat.helpers")
local conf = require("telescope.config")
local config = require("codecompanion.config")
local finders = require("telescope.finders")
local log = require("codecompanion.utils.log")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.pickers")
local utils = require("codecompanion.utils")

local fmt = string.format

local CONSTANTS = {
	NAME = "Changed Files",
	PROMPT = "Select changed file(s)",
}

---The Telescope provider for git changed files
---@param SlashCommand CodeCompanion.SlashCommand
---@return nil
local git_changed_files = function(SlashCommand)
	local git_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n$", "")
	if vim.v.shell_error ~= 0 then
		return log:warn("Not in a git repository")
	end

	local cmd = {
		"bash",
		"-c",
		"git status --porcelain -u | grep -v '^.D' | cut -c4-",
	}

	pickers
		.new({}, {
			prompt_title = CONSTANTS.PROMPT,
			finder = finders.new_oneshot_job(cmd, { entry_maker = make_entry.gen_from_file({ cwd = git_root }) }),
			previewer = conf.values.file_previewer({}),
			sorter = conf.values.generic_sorter({}),
			layout_config = {
				width = 0.75,
				height = 0.75,
				scroll_speed = 4,
			},
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local picker = action_state.get_current_picker(prompt_bufnr)
					local selections = picker:get_multi_selection()

					-- Fallback to single selection if no multi-selection is made
					if vim.tbl_isempty(selections) then
						table.insert(selections, action_state.get_selected_entry())
					end

					actions.close(prompt_bufnr)

					for _, selection in ipairs(selections) do
						if selection then
							SlashCommand:output({
								path = selection.path or selection.value,
								relative_path = selection.filename
									or vim.fn.fnamemodify(selection.path or selection.value, ":."),
							})
						end
					end
				end)
				return true
			end,
		})
		:find()
end

---@class CodeCompanion.SlashCommand.ChangedFiles: CodeCompanion.SlashCommand
local SlashCommand = {}

---@param args CodeCompanion.SlashCommandArgs
function SlashCommand.new(args)
	local self = setmetatable({
		Chat = args.Chat,
		config = args.config,
		context = args.context,
		opts = args.opts,
	}, { __index = SlashCommand })

	return self
end

---Execute the slash command
---@param SlashCommands CodeCompanion.SlashCommands
---@return nil
function SlashCommand:execute(SlashCommands)
	if not config.can_send_code() and (self.config.opts and self.config.opts.contains_code) then
		return log:warn("Sending of code has been disabled")
	end
	return git_changed_files(self)
end

---@param selected { path: string, relative_path: string?, description: string? }
function SlashCommand:read(selected)
	local ok, content = pcall(function()
		return Path.new(selected.path):read()
	end)

	if not ok then
		return ""
	end

	local ft = vim.filetype.match({ filename = selected.path })
	local relative_path = vim.fn.fnamemodify(selected.path, ":.")
	local id = "<file>" .. relative_path .. "</file>"

	return content, ft, id, relative_path
end

---Output from the slash command in the chat buffer
---@param selected { path: string, relative_path?: string, description?: string }
---@param opts? { message?:string, description?: string, silent: boolean, pin: boolean }
---@return nil
function SlashCommand:output(selected, opts)
	if not config.can_send_code() and (self.config.opts and self.config.opts.contains_code) then
		return log:warn("Sending of code has been disabled")
	end
	opts = opts or {}

	if selected.description then
		opts.message = selected.description
	end

	local content, id, relative_path, _, _ = chat_helpers.format_file_for_llm(selected.path, opts)

	self.Chat:add_message({
		role = config.constants.USER_ROLE,
		content = content or "",
	}, {
		visible = false,
		context = { id = id, path = selected.path },
		_meta = { tag = "changed_file" },
	})

	if opts.pin then
		return
	end

	self.Chat.context:add({
		id = id or "",
		path = selected.path,
		source = "utils.codecompanion.slash_commands.changed_files",
	})

	if opts.silent then
		return
	end

	utils.notify(fmt("Added changed file `%s` to the chat", vim.fn.fnamemodify(relative_path, ":t")))
end

return SlashCommand
