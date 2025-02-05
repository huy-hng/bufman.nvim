local Path = require('plenary.path')
local config = require('bufman.config')

local M = {}

function M.normalize_path(item)
	if string.find(item, '.*:///.*') ~= nil then return item end
	return Path:new(item):normalize()
end

function M.get_icon(filename, opts)
	opts = vim.tbl_extend('force', {
		padding = 1,
		hexcode = false,
		default = true,
	}, opts or {})

	local icon = ' '
	local hl = ''
	local devicons = require('nvim-web-devicons')

	if devicons then
		local extension = M.get_extension(filename)
		local icon_fn = opts.hexcode and devicons.get_icon_color or devicons.get_icon

		local f_icon, f_hl = icon_fn(filename, extension, { default = opts.default })
		if f_icon and opts.padding > 0 then --
			icon = f_icon .. vim.fn['repeat'](' ', opts.padding)
		end
		hl = f_hl and f_hl or hl
	end
	return { icon, hl }
end

function M.get_path_folders(filename, folder_amount, normalized)
	folder_amount = folder_amount or 0

	if normalized then
		local normalized = M.normalize_path(filename)
		if type(normalized) ~= 'table' then filename = normalized end
	end

	local path = vim.fn.fnamemodify(filename, ':h')
	local split = path:split('/')

	if folder_amount == 0 then return split, 0 end

	local folders = {}
	if folder_amount > 0 and #split > 0 then
		for i = #split - (folder_amount - 1), #split do
			table.insert(folders, split[i])
		end
	end

	local truncated = (#split - folder_amount)

	return folders, truncated
end

function M.get_filename(filename, remove_extension)
	local mods = ':t'
	if remove_extension then mods = mods .. ':r' end
	return filename == '' and '[No Name]' or vim.fn.fnamemodify(filename, mods)
end

function M.get_extension(filename) --
	return vim.fn.fnamemodify(filename, ':e')
end

function M.test(item)
	return Path:new(item):shorten()
end

function M.build_path(bufnr)
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	local paths = M.get_path_folders(bufname, 0, conf.show_relative_path)
	local path = {}
	for _, dir in ipairs(paths) do
		table.insert(path, {dir, 'Directory'})
		table.insert(path, {'/', 'NonText'})
	end
	return path
end

function M.build_default_bufname(bufnr)
	local conf = config.get_config()
	local content = {}

	local bufname = vim.api.nvim_buf_get_name(bufnr)

	local icon_hl = M.get_icon(bufname)
	table.insert(content, icon_hl)
	
	local path = M.build_path(bufnr)
	for _, path_hl in ipairs(path) do
		table.insert(content, path_hl)
	end

	local fname = M.get_filename(bufname, true)
	local extension = M.get_extension(bufname)

	table.insert(content, {fname, 'Title'})
	table.insert(content, {'.' .. extension .. ' ', 'NonText'})

	return content
end

function M.build_filename(bufnr)
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	
	local content = {}
	table.insert(content, M.get_icon(bufname))
	table.insert(content, {M.get_filename(bufname, true), 'Title'})
	table.insert(content, {'.' .. M.get_extension(bufname) .. ' ', 'NonText'})
	return content
end


return M
