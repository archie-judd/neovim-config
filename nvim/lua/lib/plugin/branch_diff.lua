local M = {}

function M.resolve_ref(ref, use_merge_base)
	if not ref then
		local remote_head = vim.fn.system("git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null"):gsub("\n", "")
		if remote_head == "" then
			vim.notify(
				"BranchDiff: could not detect origin/HEAD. "
					.. "Try: git remote set-head origin --auto, "
					.. "or pass a branch explicitly e.g. :BranchDiff origin/main",
				vim.log.levels.ERROR
			)
			return nil
		end
		ref = remote_head:gsub("refs/remotes/", "")
	end

	if not use_merge_base then
		return ref
	end

	local base = vim.fn.system("git merge-base HEAD " .. ref .. " 2>/dev/null"):gsub("\n", "")
	if base == "" then
		vim.notify(
			"BranchDiff: git merge-base failed for ref '"
				.. ref
				.. "'. "
				.. "Make sure the ref exists and you are inside a git repo.",
			vim.log.levels.ERROR
		)
		return nil
	end
	return base
end

function M.close_diffview_tabs()
	for _, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
		for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(tabnr)) do
			local buf = vim.api.nvim_win_get_buf(winid)
			local ft = vim.bo[buf].filetype
			if ft:match("^Diffview") then
				vim.api.nvim_set_current_tabpage(tabnr)
				vim.cmd("DiffviewClose")
				break
			end
		end
	end
end

return M
