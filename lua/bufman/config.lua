local M = { config = {} }

function M.init(user_config) --
	M.config = vim.tbl_deep_extend('force', M.default_config, user_config or {})
end

function M.get_config() return M.config end

M.default_config = {
	line_keys = '1234567890',
	keymaps = {
		['<CR>'] = 'edit',
		['<ESC>'] = 'close',
		['q'] = 'close',
	},
	-- width and height can be an integer or a float between 0 and 1, which is the size relative to the screen
	width = 80,
	height = 20,

	buffer_delete_cmd = 'bdelete',

	show_relative_path = true,

	-- transparency
	winblend = 0,
	cursorline = true,
	short_term_names = false,
	-- highlight = 'Float',
	-- borderchars = { '─', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
	borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
	highlight = 'Normal',

	-- sets the cursor on alt buffer instead of current buffer
	focus_alternate_buffer = false,
}

return M
