local M = {}

---Clear copy registers
---@param ... string
function M.clear_registers(...)
	local registers = { ... }
	for _, reg in ipairs(registers) do
		vim.fn.setreg(reg, "")
	end
	vim.notify("Cleared registers: " .. table.concat(registers, ", "), vim.log.levels.INFO)
	vim.cmd(":wshada!")
end

return M
