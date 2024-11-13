local utils = require("utils")
local config = require("config").opts.clipboard
local M = {}

---@return string|nil
M.get_content = function()
	local command = config.cmd .. " " .. config.args
	local output, exit_code = utils.execute(command)
	if exit_code == 0 then
		return output
	end

	return nil
end

return M
