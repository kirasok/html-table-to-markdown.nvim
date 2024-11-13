local utils = require("utils")
local config = require("config").opts.pandoc

local M = {}

---@param html string
---@return string? markdown
M.convert = function(html)
	local command = config.cmd .. " " .. config.args
	local output, exit_code = utils.execute(command, html)
	if exit_code == 0 then
		return output
	end
end

return M
