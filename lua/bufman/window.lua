local popup = require('plenary.popup')
local config = require('bufman.config')
local buffer = require('bufman.buffer')

local M = {
	win_id = nil,
	bufnr = nil,
}

local function set_buf_lines(contents, current_buf_line, allow_undo)
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
	if not allow_undo then disallow_undo() end

	vim.api.nvim_buf_set_lines(M.bufnr, 0, #contents, false, contents)

	-- set cursor to current buffer
	if current_buf_line then vim.fn.cursor { current_buf_line, 1 } end

	if not allow_undo then allow_undo(undolevels) end
end

local function select_item_cb()
	local function set_current_buffer(id)
		local buffer = buffer.buffer_list[id]
		if not buffer then return end

		pcall(vim.api.nvim_set_current_buf, buffer.bufnr)
	end

	local function is_buffer_in_list(bufname)
		for _, bufer in ipairs(M.buffer_list) do
			if bufer.filename == bufname then return true end
		end
	end

	local function is_deletable(bufnr)
		local buftype = vim.bo[bufnr].buftype
		return (
			vim.api.nvim_buf_is_valid(bufnr)
			and buftype ~= 'terminal'
			and not vim.bo[bufnr].modified
			and bufnr ~= -1
		)
	end

	local selected_line = vim.fn.line('.')
	if vim.api.nvim_buf_get_changedtick(M.bufnr) > 0 then
		-- check if lines have been moved and update buffer_list
		buffer.update_buffer_list()
	end

	M.close_menu()
	set_current_buffer(selected_line)

	for _, mark in ipairs(M.window_buffers) do
		if not is_buffer_in_list(mark.filename) and is_deletable(mark.bufnr) then
			vim.cmd.Bdelete(mark.bufnr)
		end
	end
end

local function create_window(config)
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
		vim.api.nvim_set_option_value('bufhidden', 'delete', { buf = bufnr })
	end

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

	vim.api.nvim_win_close(M.win_id, true)

	M.win_id = nil
	M.bufnr = nil
end

function M.open_menu(user_config)
	local merged_config = vim.tbl_deep_extend('force', config.get_config(), user_config or {})
	local win_info = create_window(merged_config)

	P(win_info)
	M.win_id = win_info.win_id
	M.bufnr = win_info.bufnr
	require('bufman.keymaps').set_keymaps()

	local current_buf = vim.api.nvim_get_current_buf()
	set_buf_lines(buffer.get_buffer_list(current_buf))
end

function M.toggle_menu(user_config)
	if M.win_id ~= nil then
		M.close_menu()
		return
	end
	M.open_menu(user_config)
end

return M
