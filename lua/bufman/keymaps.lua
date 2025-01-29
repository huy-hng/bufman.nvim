local config = require('bufman.config')
local window = require('bufman.window')
local buffer = require('bufman.buffer')

local M = {}

action_lookup = {
	edit = function(bufnr) pcall(vim.api.nvim_set_current_buf, bufnr) end,
	close = window.close_menu,
	open = window.open_menu,
}

function M.set_keymaps()
	conf = config.get_config()
	for key, action in pairs(conf.keymaps) do
		vim.keymap.set('n', key, action_lookup[action], { buffer = true })
	end
end

local function set_current_buffer(id)
	local buffer = buffer.buffer_list[id]
	if not buffer then return end

	pcall(vim.api.nvim_set_current_buf, buffer.bufnr)
end

return M
