local config = require('bufman.config')
local window = require('bufman.window')
local buffer = require('bufman.buffer')

local M = {}

local function edit_buffer()
	local bufnr = tonumber(vim.fn.getline(vim.fn.line('.')))
	window.close_menu()
	if bufnr then vim.api.nvim_set_current_buf(bufnr) end
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
