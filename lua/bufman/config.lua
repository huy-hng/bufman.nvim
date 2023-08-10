local utils = require('bufman.utils')

local M = {}
M.config = {}

function M.init(user_config) --
	M.config = utils.merge_tables(M.default_config, user_config or {})

	local line_keys = {}
	for i = 1, #M.config.line_keys do
		local key = M.config.line_keys:sub(i, i)
		table.insert(line_keys, key)
	end
	M.config.line_keys = line_keys
end

local sorting_functions = {
	alphabet = {
		function(a, b)
			if not a or not b then return false end
			-- return filename.get_short_file_name(a.filename) < filename.get_short_file_name(b.filename)
			return a.filename < b.filename
		end,
		key = 'a',
	},
	bufnr = {
		function(a, b) return a.bufnr < b.bufnr end,
		key = 'r',
	},
}

M.default_config = {
	line_keys = '1234567890',
	-- line_keys = 'qwfphuyj',
	select_menu_item_commands = {
		edit = '<CR>',
	},
	sorting = {
		functions = sorting_functions,
	},
	height = 20,
	width = 80,
	winblend = nil,
	focus_alternate_buffer = false,
	short_file_names = false,
	cursorline = true,
	short_term_names = false,
	highlight = 'Float',
	-- borderchars = { '─', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
	borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
	-- highlight = 'Normal',
	-- width = 0.5,
	-- height = 0.5
}

return M
