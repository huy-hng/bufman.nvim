local utils = require('bufman.utils')
local sorter = require('bufman.sorter')
local config = require('bufman.config')

local M = {
	buffer_list = {},
}

local function remove_buffers()
	for i, mark in ipairs(M.buffer_list) do
		if not utils.is_valid_buffer(mark.bufnr, mark.filename) then --
			table.remove(M.buffer_list, i)
		end
	end
end

local function add_buffers()
	local function is_buffer_in_marks(bufname)
		for _, mark in ipairs(M.buffer_list) do
			if mark.filename == bufname then return true end
		end
	end

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		local bufname = vim.api.nvim_buf_get_name(bufnr)

		if utils.is_valid_buffer(bufnr, bufname) and not is_buffer_in_marks(bufname) then
			-- TODO: if sorting / grouping is enabled then this should be more complex
			table.insert(M.buffer_list, { filename = bufname, bufnr = bufnr })
		end
	end
end

function M.update_buffer_list()
	remove_buffers()
	add_buffers()
end

function M.get_buffer_list(current_buf)
	local conf = config.get_config()
	current_buf = conf.focus_alternate_buffer and vim.fn.bufnr('#') or current_buf

	local contents = {}
	local current_buf_line

	for i, buffer in ipairs(M.buffer_list) do
		if buffer.bufnr == current_buf then current_buf_line = i end
		table.insert(contents, buffer.filename)
	end
	return contents, current_buf_line
end

M.update_buffer_list()

-- P(M.buffer_list)
local sorter = require('bufman.sorter')
sorter.sort('path', M.buffer_list)
-- P(M.buffer_list)

return M
