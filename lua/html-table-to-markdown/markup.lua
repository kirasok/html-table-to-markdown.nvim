local M = {}

---@param input string
function M.insert_markup(input)
	vim.api.nvim_put({ input }, "l", true, true)
end
return M
