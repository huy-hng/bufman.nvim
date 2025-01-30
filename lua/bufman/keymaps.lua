local config = require('bufman.config')
local window = require('bufman.window')
local buffer = require('bufman.buffer')

local M = {}

local function select_item_cb()
	local function set_current_buffer(id)
		local buf_list = buffer.buffer_list[id]
		if not buf_list then return end

		pcall(vim.api.nvim_set_current_buf, buf_list.bufnr)
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
	if vim.api.nvim_buf_get_changedtick(window.bufnr) > 0 then
		-- check if lines have been moved and update buffer_list
		buffer.update_buffer_list()
	end

	window.close_menu()
	set_current_buffer(selected_line)

	for _, mark in ipairs(M.window_buffers) do
		if not is_buffer_in_list(mark.filename) and is_deletable(mark.bufnr) then
			vim.cmd.Bdelete(mark.bufnr)
		end
	end
end

local function edit_buffer()
	local selected_line = vim.fn.line('.')
	-- local status, res = pcall(vim.api.nvim_set_current_buf, tonumber(selected_line))
	local bufnr = tonumber(selected_line)
	window.close_menu()
	if bufnr then vim.api.nvim_set_current_buf(bufnr) end
	-- P(selected_line, status, res)
end

action_lookup = {
	edit = edit_buffer,
	close = window.close_menu,
	open = window.open_menu,
}

function M.set_keymaps()
	conf = config.get_config()
	for key, action in pairs(conf.keymaps) do
		vim.keymap.set('n', key, action_lookup[action], { buffer = true })
	end
end

return M
