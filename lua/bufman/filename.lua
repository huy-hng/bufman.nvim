local Path = require('plenary.path')

local M = {}

local function get_extension(filename) --
	return vim.fn.fnamemodify(filename, ':e')
end

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
	local devicons = require('nvim-web-devicons')

	if devicons then
		local extension = get_extension(filename)
		local icon_fn = opts.hexcode and devicons.get_icon_color or devicons.get_icon

		local f_icon, f_hl = icon_fn(filename, extension, { default = opts.default })
		if f_icon and opts.padding > 0 then --
			icon = f_icon .. vim.fn['repeat'](' ', opts.padding)
		end
		hl = f_hl and f_hl or hl
	end
	return { icon, hl }
end

return M
