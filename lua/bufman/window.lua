local popup = require('plenary.popup')
local config = require('bufman.config')
local buffer = require('bufman.buffer')
local extmark = require('bufman.extmark')

local M = {
	win_id = nil,
	bufnr = nil,
}

local function set_buf_lines(contents)
	local function get_undolevels()
		return vim.api.nvim_get_option_value('undolevels', { buf = M.bufnr })
	end

	local function disallow_undo()
		vim.api.nvim_set_option_value('undolevels', -1, { buf = M.bufnr })
	end

	local function allow_undo(undolevels)
		vim.api.nvim_set_option_value('undolevels', undolevels, { buf = M.bufnr })
	end

	local undolevels = get_undolevels()
	disallow_undo()

	vim.api.nvim_buf_set_lines(M.bufnr, 0, #contents, false, contents)

	allow_undo(undolevels)
end

local function set_options(bufnr, win_id)
	if config.cursorline then
		vim.api.nvim_set_option_value('cursorline', true, { win = win_id })
		vim.api.nvim_set_option_value('cursorlineopt', 'both', { win = win_id })
	end

	vim.api.nvim_buf_set_name(bufnr, 'Bufman')

	vim.api.nvim_set_option_value('wrap', false, { win = win_id })
	vim.api.nvim_set_option_value('number', true, { win = win_id })

	vim.api.nvim_set_option_value('filetype', 'bufman', { buf = bufnr })
	vim.api.nvim_set_option_value('buftype', 'acwrite', { buf = bufnr })
	-- vim.api.nvim_set_option_value('buftype', 'nowrite', { buf = bufnr })
	vim.api.nvim_set_option_value('bufhidden', 'delete', { buf = bufnr })
end

local function create_window(config)
	local width = config.width
	local height = config.height

	if width <= 1 then width = math.floor(vim.o.columns * config.width) end
	if height <= 1 then height = math.floor(vim.o.lines * config.height) end
	local bufnr = vim.api.nvim_create_buf(false, false)

	local win_config = {
		title = 'Bufman',
		line = math.floor(((vim.o.lines - height) / 2) - 1),
		col = math.floor((vim.o.columns - width) / 2),
		minwidth = width,
		minheight = height,
		borderchars = config.borderchars,
	}

	if config.highlight ~= '' then win_config['highlight'] = config.highlight end
	local win_id, win = popup.create(bufnr, win_config)

	if config.winblend then
		vim.wo[win_id].winblend = 100
		vim.wo[win.border.win_id].winblend = config.winblend
	end

	if config.highlight ~= '' then
		vim.api.nvim_set_option_value(
			'winhl',
			config.highlight .. ':' .. config.highlight,
			{ win = win.border.win_id }
		)
	end
	set_options(bufnr, win_id)

	return { bufnr = bufnr, win_id = win_id }
end

function M.close_menu()
	if M.win_id == nil or not vim.api.nvim_win_is_valid(M.win_id) then return end

	buffer.sync_buffer_list()
	vim.api.nvim_win_close(M.win_id, true)

	M.win_id = nil
	M.bufnr = nil
end

function M.open_menu(user_config)
	buffer.update_buffer_list()

	-- get current buffer
	local current_buf = vim.api.nvim_get_current_buf()

	local merged_config = vim.tbl_deep_extend('force', config.get_config(), user_config or {})
	local win_info = create_window(merged_config)

	M.win_id = win_info.win_id
	M.bufnr = win_info.bufnr
	require('bufman.keymaps').set_keymaps()
	P(M.bufnr)

	-- buffer.update_buffer_list(M.bufnr)

	-- set buffer_content
	local buffer_list_string = vim.tbl_map(
		function(buf) return tostring(buf) end,
		buffer.buffer_list
	)
	set_buf_lines(buffer_list_string)

	-- set_options(M.bufnr, M.win_id)

	local current_buf_line
	-- set_extmarks
	for i, bufnr in pairs(buffer.buffer_list) do
		if bufnr == current_buf then current_buf_line = i end
		extmark.set_extmark(M.bufnr, i - 1, { { vim.api.nvim_buf_get_name(bufnr) } })
	end

	-- set cursor to current buffer
	if current_buf_line then vim.fn.cursor { current_buf_line, 1 } end
end

function M.toggle_menu(user_config)
	if M.win_id ~= nil then
		M.close_menu()
		return
	end
	M.open_menu(user_config)
end

return M
