local clipboard = require("clipboard")
local pandoc = require("pandoc")
local markup = require("markup")

vim.api.nvim_create_user_command("PasteMarkdownTableFromHtmlFromClipboard", function()
	local html = clipboard.get_content()
	if not html then
		return
	end
	local markdown = pandoc.convert(html)
	if not markdown then
		return
	end
	markup.insert_markup(markdown)
end, { desc = "Insert markdown table from html table" })
