local config = require('bufman.config')

local M = {}

function M.setup(user_config)
	config.init(user_config)

	vim.api.nvim_set_hl(0, 'BufmanHiddenCursor', { blend = 100, nocombine = true })
	local list_manger = require('bufman.list_manager')

	Augroup('Bufman', {
		Autocmd('SessionLoadPost', { list_manger.synchronize_cache, true }),
		Autocmd(
			{ 'BufDelete', 'BufLeave', 'BufNew', 'BufEnter', 'BufRead' },
			list_manger.synchronize_cache
		),
	})
end

return M
