local M = {}

local path = vim.fn.getcwd() .. "/.context_bundle.xml"

M.bundle_path = function(args)
	return path
end

M.bundle_content = function(args)
	local f = io.open(path, "r")
	if f then
		local content = f:read("*a")
		f:close()
		return content
	end
	return "ERROR: context bundle not found at " .. path .. "\nRun the Context Retrieval prompt first."
end

return M
