local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local conf = require("telescope.config")
local dap = require("dap")
local dap_breakpoints = require("dap.breakpoints")
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local strings = require("plenary.strings")
local telescope = require("telescope")
local telescope_utils = require("telescope.utils")

local get_breakpoints = function()
	local response = dap_breakpoints.get()
	local breakpoints = {}

	for bufnum, breakpoints_raw in pairs(response) do
		local buffer_name = vim.api.nvim_buf_get_name(bufnum)
		for _, bp_raw in ipairs(breakpoints_raw) do
			table.insert(breakpoints, {
				active = true,
				bufnum = bufnum,
				filename = buffer_name,
				lnum = bp_raw.line,
				condition = bp_raw.condition,
			})
		end
	end

	return breakpoints
end

local relative_path_for_abs_path = function(absolute_path)
	local cwd = vim.fn.getcwd() -- Get the current working directory
	return vim.fn.fnamemodify(absolute_path, ":." .. cwd)
end

local make_display_frame = function(entry)
	local icon, icon_hl = telescope_utils.get_devicons(entry.filename)
	local icon_width = strings.strdisplaywidth(icon)
	local displayer = entry_display.create({
		separator = " ",
		items = {
			{ width = 3 },
			{ width = icon_width },
			{ remaining = true },
		},
	})
	return displayer({
		entry.frame.id,
		{ icon, icon_hl },
		relative_path_for_abs_path(entry.filename) .. ":" .. entry.lnum,
	})
end

local get_frame_finder = function(frames)
	local finder = finders.new_table({
		results = frames,
		entry_maker = function(frame)
			local entry = {
				frame = frame,
				filename = frame.source.path,
				lnum = frame.line,
				display = make_display_frame,
				ordinal = frame.id,
			}
			return entry
		end,
	})
	return finder
end

local get_frames = function()
	local session = dap.session()
	local frames = {}
	if session ~= nil then
		local thread = session.threads[session.stopped_thread_id]
		frames = thread.frames
	end
	return frames
end

local set_frame = function(prompt_bufnr)
	local selection = actions_state.get_selected_entry()
	local session = dap.session()
	actions.close(prompt_bufnr)
	if session ~= nil then
		session:_frame_set(selection.frame)
	end
end

local make_breakpoint_display = function(entry)
	local icon, icon_hl = telescope_utils.get_devicons(entry.filename)
	local icon_width = strings.strdisplaywidth(icon)
	local displayer = entry_display.create({
		separator = " ",
		items = {
			{ width = 3 },
			{ width = icon_width },
			{ remaining = true },
		},
	})
	return displayer({
		entry.breakpoint.active and "[✓]" or "[X]",
		{ icon, icon_hl },
		relative_path_for_abs_path(entry.filename) .. ":" .. entry.lnum,
	})
end

local get_breakpoint_finder = function(results)
	local finder = finders.new_table({
		results = results,
		entry_maker = function(result)
			local entry = {
				filename = result.filename,
				lnum = result.lnum,
				breakpoint = result,
				display = make_breakpoint_display,
				ordinal = 1,
			}
			return entry
		end,
	})
	return finder
end

---Replace the word under the cursor with the selected entry
local toggle_breakpoint = function(prompt_bufnr)
	local picker = actions_state.get_current_picker(prompt_bufnr)
	local row = picker:get_selection_row()
	local entries = picker.finder.results
	local selection = actions_state.get_selected_entry()
	local active = nil
	if selection.breakpoint.active == false then
		dap_breakpoints.set({}, selection.breakpoint.bufnum, selection.breakpoint.lnum)
		active = true
	else
		dap_breakpoints.remove(selection.breakpoint.bufnum, selection.breakpoint.lnum)
		active = false
	end
	local breakpoints = {}
	for i, entry in ipairs(entries) do
		if
			entry.breakpoint.bufnum == selection.breakpoint.bufnum
			and entry.breakpoint.lnum == selection.breakpoint.lnum
		then
			entry.breakpoint.active = active
		end
		table.insert(breakpoints, entry.breakpoint)
	end
	picker.finder = get_breakpoint_finder(breakpoints)
	picker:refresh()
	vim.wait(10) -- wait for the refresh to finish
	picker:set_selection(row)
end

local function dap_commands()
	local results = {}
	for k, v in pairs(dap) do
		if type(v) == "function" then
			table.insert(results, k)
		end
	end

	pickers
		.new({}, {
			prompt_title = "Dap Commands",
			finder = finders.new_table({
				results = results,
			}),
			sorter = conf.values.generic_sorter(),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local selection = actions_state.get_selected_entry()
					actions.close(prompt_bufnr)

					dap[selection.value]()
				end)

				return true
			end,
		})
		:find()
end

local function dap_frames()
	local frames = get_frames()
	pickers
		.new({}, {
			prompt_title = "Dap Stack Frames",
			finder = get_frame_finder(frames),
			previewer = conf.values.grep_previewer({}),
			sorter = conf.values.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(set_frame)
				return true
			end,
			layout_config = {
				width = 0.75,
				height = 0.75,
				scroll_speed = 4,
			},
		})
		:find()
end

local function _dap_breakpoints()
	local results = get_breakpoints()
	pickers
		.new({}, {
			prompt_title = "Dap Breakpoints",
			finder = get_breakpoint_finder(results),
			previewer = conf.values.grep_previewer({}),
			sorter = conf.values.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.toggle_selection:replace(toggle_breakpoint)
				return true
			end,
			layout_config = {
				width = 0.75,
				height = 0.75,
				scroll_speed = 4,
			},
		})
		:find()
end

return telescope.register_extension({
	setup = function(ext_config, config) end,
	exports = {
		dap_breakpoints = _dap_breakpoints,
		dap_commands = dap_commands,
		dap_frames = dap_frames,
	},
})
