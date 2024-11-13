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
local opts = {
	pandoc = {
		cmd = "pandoc",
		args = "-f html -t gfm-raw_html",
	},
	clipboard = {
		cmd = "wl-paste",
		args = "-t text/plain",
	},
}

---@param options HTTM.Config?
local function setup_options(options)
	opts = opts or vim.tbl_deep_extend("force", opts, options)
end

---@type string exec
---@return boolean
local function executable(exec)
	return vim.fn.executable(exec) == 1
end

---@type string message
---@return nil
local function echo(message)
	vim.api.nvim_echo({
		{ "html-table-to-markdown", "ErrorMsg" },
		{ " " .. message },
	}, true, {})
end

---@param feature string
local function has(feature)
	return vim.fn.has(feature) == 1
end

---@param input_cmd string
---@param input? string
---@param execute_directly? boolean
---@return string | nil output
---@return number exit_code
local function execute(input_cmd, input, execute_directly)
	local shell = vim.o.shell:lower()
	local cmd

	-- execute command directly if shell is powershell or pwsh or explicitly requested
	if execute_directly or shell:match("powershell") or shell:match("pwsh") then
		cmd = input_cmd

	-- WSL requires the command to have the format:
	-- powershell.exe -Command 'command "path/to/file"'
	elseif has("wsl") then
		if input_cmd:match("curl") then
			cmd = input_cmd
		else
			cmd = "powershell.exe -NoProfile -Command '" .. input_cmd:gsub("'", '"') .. "'"
		end

	-- cmd.exe requires the command to have the format:
	-- powershell.exe -Command "command 'path/to/file'"
	elseif has("win32") then
		cmd = 'powershell.exe -NoProfile -Command "' .. input_cmd:gsub('"', "'") .. '"'

	-- otherwise (linux, macos), execute the command directly
	else
		cmd = "sh -c " .. vim.fn.shellescape(input_cmd)
	end

	local output = vim.fn.system(cmd, input)
	local exit_code = vim.v.shell_error

	return output, exit_code
end

---@return string|nil
local function get_content()
	local command = opts.clipboard.cmd .. " " .. opts.clipboard.args
	local output, exit_code = execute(command)
	if exit_code == 0 then
		return output
	end

	return nil
end

---@param html string
---@return string? markdown
local function convert(html)
	local command = opts.pandoc.cmd .. " " .. opts.pandoc.args
	local output, exit_code = execute(command, html)
	if exit_code == 0 then
		return output
	end
end

---@param string string
---@param pattern string
local function split(string, pattern)
	if pattern == nil then
		pattern = "%s"
	end
	local t = {}
	for str in string.gmatch(string, "([^" .. pattern .. "]+)") do
		table.insert(t, str)
	end
	return t
end

---@param input string
local function insert_markup(input)
	vim.api.nvim_put(split(input, "\n"), "l", true, true)
end

local M = {}

---@param options HTTM.Config?
M.setup = function(options)
	setup_options(options)
	if not executable(opts.pandoc.cmd) then
		echo("Can't find " .. opts.pandoc.cmd)
	end
	if not executable(opts.clipboard.cmd) then
		echo("Can't find " .. opts.clipboard.cmd)
	end

	vim.api.nvim_create_user_command("PasteMarkdownTableFromHtmlFromClipboard", function()
		local html = get_content()
		if not html then
			return
		end
		local markdown = convert(html)
		if not markdown then
			return
		end
		insert_markup(markdown)
	end, { desc = "Insert markdown table from html table" })
end

return M
