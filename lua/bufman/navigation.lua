local list_manager = require('bufman.list_manager')

local M = {}

function M.set_current_buffer(id, command)
	if command == nil then command = 'edit' end

	local buffer = list_manager.buffer_list[id]
	if not buffer then return end

	vim.api.nvim_set_current_buf(buffer.bufnr)
end

local function get_current_buf_line()
	local current_buf_id = vim.fn.bufnr()
	for idx, mark in pairs(list_manager.buffer_list) do
		if mark.bufnr == current_buf_id then return idx end
	end
	return -1
end

function M.goto(direction)
	-- list_manager.synchronize_marks()

	local current_line = get_current_buf_line()
	if current_line == -1 then return end

	local target_line = current_line + direction
	if target_line < 1 then
		target_line = #list_manager.buffer_list
	elseif target_line > #list_manager.buffer_list then
		target_line = 1
	end

	M.set_current_buffer(target_line)
end

function M.location_window(options)
	local default_options = {
		relative = 'editor',
		style = 'minimal',
		width = 30,
		height = 15,
		row = 2,
		col = 2,
	}
	options = vim.tbl_extend('keep', options, default_options)

	local bufnr = options.bufnr or vim.api.nvim_create_buf(false, true)
	local win_id = vim.api.nvim_open_win(bufnr, true, options)

	return {
		bufnr = bufnr,
		win_id = win_id,
	}
end

return M
