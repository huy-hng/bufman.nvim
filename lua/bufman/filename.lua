local Path = require('plenary.path')

local M = {}

function M.normalize_path(item)
	if string.find(item, '.*:///.*') ~= nil then return item end
	return Path:new(item):normalize()
	-- return Path:new(Path:new(item):absolute()):make_relative(vim.loop.cwd())
end

function M.get_icon(filename, opts)
	opts = vim.tbl_extend('force', {
		padding = 1,
		hexcode = false,
		default = true,
	}, opts or {})

	local icon = ' '
	local hl = ''
	local devicons = nrequire('nvim-web-devicons')

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

function M.get_path_folders(filename, folder_amount, normalize)
	folder_amount = folder_amount or 0

	if Util.nil_or_true(normalize) then --
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

----------------------------------------------referenece--------------------------------------------

local function truncate_path(filename, folder_amount, add_icon)
	local folders, truncated = M.get_path_folders(filename, folder_amount)
	local sep = '  '
	local path = string.join(folders, sep)
	-- local truncation = truncated > 0 and '(' .. truncated .. ')' .. sep or ''
	local truncation = truncated > 0 and '..' .. truncated .. sep or ''

	local icon = add_icon and M.get_icon(filename)[1] or ''

	filename = M.get_filename(filename)
	return icon .. truncation .. path .. filename
	-- return truncation .. path .. filename
end

return M
