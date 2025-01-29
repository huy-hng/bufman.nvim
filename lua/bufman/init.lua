local M = {}

function M.setup(user_config)
	local config = require('bufman.config')
	config.init(user_config)

	local window = require('bufman.window')
	M.open_menu = window.open_menu
	M.close_menu = window.close_menu
	M.toggle_menu = window.toggle_menu
end

return M
