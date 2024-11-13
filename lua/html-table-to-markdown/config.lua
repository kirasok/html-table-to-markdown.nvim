local M = {}

---@class HTTM.Config.Pandoc
---@field cmd string
---@field args string

---@class HTTM.Config.Clipboard
---@field cmd string
---@field args string

---@class HTTM.Config
---@field pandoc HTTM.Config.Pandoc
---@field clipboard HTTM.Config.Clipboard

---@type HTTM.Config
M.opts = {
	pandoc = {
		cmd = "pandoc",
		args = "-f html -t gfm-raw_html",
	},
	clipboard = {
		cmd = "wl-paste",
		args = "-t text/plain",
	},
}

---@param opts HTTM.Config?
M.setup = function(opts)
	opts = opts or nil
	vim.tbl_deep_extend("force", M.opts, opts)
end

return M
