local M = {}

---@type string exec
---@return boolean
function M.executable(exec)
	return vim.fn.executable(exec) == 1
end

---@type string message
---@return nil
function M.echo(message)
	vim.api.nvim_echo({
		{ "html-table-to-markdown", "ErrorMsg" },
		{ " " .. message },
	}, true, {})
end

---@param feature string
function M.has(feature)
	return vim.fn.has(feature) == 1
end

---@param input_cmd string
---@param input string
---@param execute_directly? boolean
---@return string | nil output
---@return number exit_code
function M.execute(input_cmd, input, execute_directly)
	local shell = vim.o.shell:lower()
	local cmd

	-- execute command directly if shell is powershell or pwsh or explicitly requested
	if execute_directly or shell:match("powershell") or shell:match("pwsh") then
		cmd = input_cmd

	-- WSL requires the command to have the format:
	-- powershell.exe -Command 'command "path/to/file"'
	elseif M.has("wsl") then
		if input_cmd:match("curl") then
			cmd = input_cmd
		else
			cmd = "powershell.exe -NoProfile -Command '" .. input_cmd:gsub("'", '"') .. "'"
		end

	-- cmd.exe requires the command to have the format:
	-- powershell.exe -Command "command 'path/to/file'"
	elseif M.has("win32") then
		cmd = 'powershell.exe -NoProfile -Command "' .. input_cmd:gsub('"', "'") .. '"'

	-- otherwise (linux, macos), execute the command directly
	else
		cmd = "sh -c " .. vim.fn.shellescape(input_cmd)
	end

	local output = vim.fn.system(cmd, input)
	local exit_code = vim.v.shell_error

	return output, exit_code
end

return M
