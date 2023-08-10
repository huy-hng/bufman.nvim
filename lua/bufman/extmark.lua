local M = {}

---@param path string[]
---@return table
function M.get_extmark_path(path, remove_last_separator)
	local virt_line = {}

	for _, dir in ipairs(path) do
		table.insert(virt_line, { dir })
		table.insert(virt_line, { '  ', 'Operator' })
	end
	if Util.nil_or_true(remove_last_separator) then table.remove(virt_line, #virt_line) end

	return virt_line
end

function M.get_extmark_name(filename)
	local display_name = {}
	-- if add_icon then table.insert(display_name, M.get_icon(filename)) end

	local extension = '.' .. vim.fn.fnamemodify(filename, ':e')
	local fname = filename == '' and '[No Name]' or vim.fn.fnamemodify(filename, ':t:r')

	table.insert(display_name, { fname, 'Tag' })
	table.insert(display_name, { extension, 'NonText' })
	table.insert(display_name, { vim.fn['repeat'](' ', #filename) })
	return display_name
end

function M.truncate_path_hl(filename, folder_amount)
	local path = {}
	if folder_amount > 0 then
		local folders, _ = M.get_path_folders(filename, folder_amount)
		path = M.get_extmark_path(folders, false)
	end
	local icon = M.get_icon(filename)

	filename = M.get_extmark_name(filename)
	return table.add({ icon }, path, filename)
end

return M
