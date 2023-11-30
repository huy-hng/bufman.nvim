local M = {}

function M.setup(user_config)
	local config = require('bufman.config')
	config.init(user_config)

	local window = require('bufman.window')
	M.open_menu = window.open_menu
	M.close_menu = window.close_menu
	M.toggle_menu = window.toggle_menu

	-- local tab_scope = require('bufman.tab_scope')
	-- tab_scope.enable()
	-- tab_scope.on_tab_enter()

	vim.api.nvim_set_hl(0, 'BufmanHiddenCursor', { blend = 100, nocombine = true })
	local list_manger = require('bufman.list_manager')

	Augroup('Bufman', {
		-- Autocmd('SessionLoadPost', { list_manger.synchronize_buffer_list, true }),
		-- Autocmd('SessionLoadPost', list_manger.synchronize_buffer_list),
		-- Autocmd(
		-- 	{ 'BufDelete', 'BufLeave', 'BufNew', 'BufEnter', 'BufRead' },
		-- 	list_manger.synchronize_buffer_list
		-- ),
		-- Autocmd('SessionLoadPost', function() list_manger.synchronize_buffer_list() end),
		-- Autocmd(
		-- 	{ 'BufDelete', 'BufLeave', 'BufNew', 'BufEnter', 'BufRead' },
		-- 	function() list_manger.synchronize_buffer_list() end
		-- ),
	})
end

return M
