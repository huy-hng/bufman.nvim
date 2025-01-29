local config = require('bufman.config').config
local M = {}

_G.Bufman = {
	statuscolumn = {
		line_number = function()
			local key = config.line_keys[vim.v.lnum]
			return (key or vim.v.lnum) .. ' '
		end,
	},
}

function M.set() vim.wo.statuscolumn = '%=%{%v:lua.Bufman.statuscolumn.line_number()%}' end

return M
