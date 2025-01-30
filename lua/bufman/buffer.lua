local utils = require('bufman.utils')
local sorter = require('bufman.sorter')
local config = require('bufman.config')

local M = {
	buffer_list = {},
}

local function remove_buffers(buffer_list)
	local function is_buffer_deleted(bufnr)
		for _, real_bufnr in ipairs(vim.api.nvim_list_bufs()) do
			if real_bufnr == bufnr then return false end
		end
		return true
	end

	for i, bufnr in ipairs(buffer_list) do
		if not utils.is_valid_buffer(bufnr) or is_buffer_deleted(bufnr) then
			table.remove(buffer_list, i)
		end
	end
end

local function add_buffers()
	local function is_buffer_in_list(real_bufnr)
		for _, bufnr in ipairs(M.buffer_list) do
			if bufnr == real_bufnr then return true end
		end
	end

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if utils.is_valid_buffer(bufnr) and not is_buffer_in_list(bufnr) then
			P(bufnr)
			-- TODO: if sorting / grouping is enabled then this should be more complex
			table.insert(M.buffer_list, bufnr)
		end
	end
end

-- change `buffer_list` according to real buffers (on open)
function M.update_buffer_list(buffer_list)
	remove_buffers(buffer_list)
	add_buffers()
end

local function get_buffer_lines(bufman_bufnr)
	local function is_white_space(str) return str:gsub('%s', '') == '' end

	local lines = vim.api.nvim_buf_get_lines(bufman_bufnr, 0, -1, true)
	local items = {}

	for _, line in ipairs(lines) do
		if not is_white_space(line) then --
			table.insert(items, line)
		end
	end

	return items
end

local function delete_buffers(buffer_list)
	local function is_buffer_in_buffer_list(real_bufnr)
		for i, bufnr in ipairs(buffer_list) do
			if bufnr == real_bufnr then return true end
		end
	end
	local delete_cmd = config.get_config().buffer_delete_cmd

	for _, real_bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if
			not utils.is_bufman_buffer(real_bufnr)
			and (not utils.is_valid_buffer(real_bufnr)
			or not is_buffer_in_buffer_list(real_bufnr))
		then
			pcall(vim.cmd[delete_cmd], real_bufnr)
		end
	end
end

-- change `buffer_list` according to changes in the bufman window (on close)
function M.sync_buffer_list()
	local buffer_lines = get_buffer_lines(require('bufman.window').bufnr)

	M.buffer_list = vim.tbl_map(
		function(bufnr_string) return tonumber(bufnr_string) end,
		buffer_lines
	)

	delete_buffers(M.buffer_list)
end

return M
