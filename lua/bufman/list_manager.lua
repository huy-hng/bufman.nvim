local Debounce = require('modules.debounce')

local config = require('bufman.config').config

local M = {}

---@alias buffer_list { bufnr: number, filename: string }[]
---@type buffer_list
M.buffer_list = {}
M.groups = {}
M.window_buffers = {}

function M.sort_marks(sorting_fn)
	M.update_buffer_list()
	if #M.buffer_list < 2 then return end
	table.sort(M.buffer_list, config.sorting.functions[sorting_fn or 'alphabet'][1])
end

local function remove_duplicates(list)
	local hash = {}
	local res = {}

	for _, mark in ipairs(list) do
		if not hash[mark.bufnr] then
			res[#res + 1] = mark
			hash[mark.bufnr] = true
		end
	end
	return res
end

local function buffer_is_valid(buf_id, buf_name) --
	return 1 == vim.fn.buflisted(buf_id) and buf_name ~= ''
end

local function get_mark_by_name(name, specific_marks)
	for _, mark in ipairs(specific_marks) do
		if name == mark.filename then return mark end
	end
end

local function can_be_deleted(bufnr)
	local buftype = vim.bo[bufnr].buftype
	return (
		vim.api.nvim_buf_is_valid(bufnr)
		and buftype ~= 'terminal'
		and not vim.bo[bufnr].modified
		and bufnr ~= -1
	)
end

local function is_buffer_in_marks(bufnr)
	for _, mark in ipairs(M.buffer_list) do
		if mark.bufnr == bufnr then return true end
	end
end

local function delete_buffers()
	for _, mark in ipairs(M.window_buffers) do
		if not is_buffer_in_marks(mark.bufnr) and can_be_deleted(mark.bufnr) then
			vim.cmd.Bdelete(mark.bufnr)
		end
	end
end

local function add_buffers()
	for i, buffer in ipairs(M.buffer_list) do
		local bufnr = vim.fn.bufnr(buffer.bufnr)

		local does_buffer_exist = bufnr ~= -1
		if not does_buffer_exist then
			vim.cmd('badd ' .. buffer.filename)
			---@diagnostic disable-next-line: param-type-mismatch
			M.buffer_list[i].bufnr = vim.fn.bufnr(buffer.filename)
		end
	end
end

-- apply changes that have been made inside the buffer manager window
function M.apply_buffer_changes()
	delete_buffers()
	-- add_buffers()
end

-- sync marks with actual buffers
local function synchronize_buffer_list(initialize)
	if initialize then M.buffer_list = {} end

	for i, mark in ipairs(M.buffer_list) do
		if not buffer_is_valid(mark.bufnr, mark.filename) then --
			table.remove(M.buffer_list, i)
		end
	end

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		local filename = vim.api.nvim_buf_get_name(bufnr)
		if buffer_is_valid(bufnr, filename) and not is_buffer_in_marks(bufnr) then
			table.insert(M.buffer_list, {
				filename = filename,
				bufnr = bufnr,
			})
		end
	end
end

M.synchronize_buffer_list = Debounce(vim.schedule_wrap(synchronize_buffer_list), 20)

-- update cache with window lines
function M.update_buffer_list()
	local window = require('bufman.window')
	M.buffer_list = table.map(function(v)
		if type(v) ~= 'string' then return end

		local filename = v
		local bufnr = nil

		local existing_mark = get_mark_by_name(filename, M.buffer_list)
		if existing_mark then
			filename = existing_mark.filename
			bufnr = existing_mark.bufnr
		else
			bufnr = vim.fn.bufnr(v)
		end

		return {
			filename = filename,
			bufnr = bufnr,
		}
	end, window.get_buffer_lines())
	M.buffer_list = remove_duplicates(M.buffer_list)
end

function M.get_ordered_bufids(should_remove_duplicates)
	M.synchronize_buffer_list()
	local marks = M.buffer_list
	if Util.nil_or_true(should_remove_duplicates) then --
		marks = remove_duplicates(M.buffer_list)
	end
	return table.map(function(mark) return mark.bufnr end, marks)
end

return M
