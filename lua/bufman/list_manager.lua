local config = require('bufman.config').config
local Debounce = require('modules.debounce')

local M = {}

---@alias cache_item { bufnr: number, filename: string, tab: number | number[] }
---@type cache_item[]
M.cache = {}
M.groups = {}
M.window_buffers = {}

function M.sort_marks(sorting_fn)
	M.update_cache()
	if #M.cache < 2 then return end
	table.sort(M.cache, config.sorting.functions[sorting_fn or 'alphabet'][1])
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
	for _, mark in ipairs(M.cache) do
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
	for i, mark in ipairs(M.cache) do
		local bufnr = vim.fn.bufnr(mark.bufnr)
		-- Add buffer only if it does not already exist
		if bufnr == -1 then
			vim.cmd('badd ' .. mark.filename)
			---@diagnostic disable-next-line: param-type-mismatch
			M.cache[i].bufnr = vim.fn.bufnr(mark.filename)
		end
	end
end

-- apply changes that have been made inside the buffer manager window
function M.apply_buffer_changes()
	delete_buffers()
	-- add_buffers()
end

-- sync marks with actual buffers
local function synchronize_cache(initialize)
	if initialize then M.cache = {} end

	-- Check if any buffer has been deleted
	-- If so, remove it from M.marks
	for i, mark in ipairs(M.cache) do
		if not buffer_is_valid(mark.bufnr, mark.filename) then --
			table.remove(M.cache, i)
		end
	end

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		local filename = vim.api.nvim_buf_get_name(bufnr)
		if buffer_is_valid(bufnr, filename) and not is_buffer_in_marks(bufnr) then
			table.insert(M.cache, {
				filename = filename,
				bufnr = bufnr,
			})
		end
	end
end

M.synchronize_cache = Debounce(vim.schedule_wrap(synchronize_cache), 20)

-- update cache with window lines
function M.update_cache()
	local window = require('bufman.window')
	M.cache = table.map(function(v)
		if type(v) ~= 'string' then return end

		local filename = v
		local bufnr = nil

		local existing_mark = get_mark_by_name(filename, M.cache)
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
	M.cache = remove_duplicates(M.cache)
end

function M.get_ordered_bufids(should_remove_duplicates)
	M.synchronize_cache()
	local marks = M.cache
	if Util.nil_or_true(should_remove_duplicates) then --
		marks = remove_duplicates(M.cache)
	end
	return table.map(function(mark) return mark.bufnr end, marks)
end

return M
