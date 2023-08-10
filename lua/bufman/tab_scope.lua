local list_manager = require('bufman.list_manager')

local M = {}

---@type buffer_list[]
M.tab_buffers = {}
M.last_tab = 0
local UNLIST = false

function M.on_tab_new_entered()
	local tab = vim.api.nvim_get_current_tabpage()
	M.tab_buffers[tab] = {}
	-- vim.bo.buflisted = true
end

function M.on_tab_enter()
	local tab = vim.api.nvim_get_current_tabpage()

	M.tab_buffers[tab] = M.tab_buffers[tab] or {}
	list_manager.buffer_list = M.tab_buffers[tab]

	if not UNLIST then return end

	for _, buf in ipairs(M.tab_buffers[tab]) do
		vim.bo[buf.bufnr].buflisted = true
	end
end

function M.on_tab_leave()
	local tab = vim.api.nvim_get_current_tabpage()
	M.tab_buffers[tab] = list_manager.buffer_list

	if not UNLIST then return end
	for _, buf in ipairs(list_manager.buffer_list) do
		vim.bo[buf.bufnr].buflisted = false
	end

	M.last_tab = tab
end

function M.on_tab_closed() M.tab_buffers[M.last_tab] = nil end

function M.print_summary()
	print('tab' .. ' ' .. 'buf' .. ' ' .. 'name')
	for tab, buf_item in pairs(M.cache) do
		for _, buf in pairs(buf_item) do
			local name = vim.api.nvim_buf_get_name(buf)
			print(tab .. ' ' .. buf .. ' ' .. name)
		end
	end
end

function M.disable() DeleteAugroup('TabScope') end

function M.enable()
	Augroup('TabScope', {
		Autocmd('TabEnter', M.on_tab_enter),
		Autocmd('TabLeave', M.on_tab_leave),
		Autocmd('TabClosed', M.on_tab_closed),
		Autocmd('TabNewEntered', M.on_tab_new_entered),
	})
	vim.api.nvim_create_user_command('ScopeSaveState', function()
		M.on_tab_leave()
		M.on_tab_enter()
	end, {})
end

return M
