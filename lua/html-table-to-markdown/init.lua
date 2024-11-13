local M = {}

---@param opts HTTM.Config?
M.setup = function(opts)
	local utils = require("utils")
	local config = require("config")

	config.setup(opts)
	if not utils.executable(config.opts.pandoc.cmd) then
		utils.echo("Can't find " .. config.opts.pandoc.cmd)
	end
	if not utils.executable(config.opts.clipboard.cmd) then
		utils.echo("Can't find " .. config.opts.clipboard.cmd)
	end

	require("commands")
end

return M
