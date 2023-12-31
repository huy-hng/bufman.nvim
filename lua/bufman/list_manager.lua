local config = require('bufman.config').config
local grouper = require('bufman.grouper')
local Debounce = require('modules.debounce')

local M = {}

---@alias mark { filename: string, bufnr: number }

---@type mark[]
M.marks = {}
M.groups = {}
M.window_marks = {}

function M.sort_marks(sorting_fn)
	M.update_marks_list()
	if #M.marks < 2 then return end
	table.sort(M.marks, config.sorting.functions[sorting_fn][1])
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
	local ref_name = nil
	for _, mark in ipairs(specific_marks) do
		ref_name = mark.filename

		-- if string.starts(mark.filename, 'term://') then
		-- 	if config.short_term_names then ref_name = fname.get_short_term_name(mark.filename) end
		-- else
		-- 	if config.short_file_names then ref_name = fname.get_short_file_name(mark.filename) end
		-- end
		if name == ref_name then return mark end
	end
	return nil
end

local function can_be_deleted(bufname, bufnr)
	return (
		vim.api.nvim_buf_is_valid(bufnr)
		and not string.starts(bufname, 'term://')
		and not vim.bo[bufnr].modified
		and bufnr ~= -1
	)
end

local function is_buffer_in_marks(bufnr)
	for _, mark in ipairs(M.marks) do
		if mark.bufnr == bufnr then return true end
	end
end

local function delete_buffers()
	for _, mark in ipairs(M.window_marks) do
		if not is_buffer_in_marks(mark.bufnr) and can_be_deleted(mark.filename, mark.bufnr) then
			vim.cmd.Bdelete(mark.bufnr)
		end
	end
end

local function add_buffers()
	for i, mark in ipairs(M.marks) do
		local bufnr = vim.fn.bufnr(mark.bufnr)
		-- Add buffer only if it does not already exist
		if bufnr == -1 then
			vim.cmd('badd ' .. mark.filename)
			M.marks[i].bufnr = vim.fn.bufnr(mark.filename)
		end
	end
end

-- apply changes that have been made inside the buffer manager window
function M.apply_buffer_changes()
	delete_buffers()
	-- add_buffers()
end

-- sync marks with actual buffers
local function synchronize_marks(initialize)
	if initialize then M.marks = {} end

	-- Check if any buffer has been deleted
	-- If so, remove it from M.marks
	for i, mark in ipairs(M.marks) do
		if not buffer_is_valid(mark.bufnr, mark.filename) then --
			table.remove(M.marks, i)
		end
	end

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		local filename = vim.api.nvim_buf_get_name(bufnr)
		if buffer_is_valid(bufnr, filename) and not is_buffer_in_marks(bufnr) then
			table.insert(M.marks, {
				filename = filename,
				bufnr = bufnr,
			})
		end
	end
end

M.synchronize_marks = Debounce(vim.schedule_wrap(synchronize_marks), 20)

-- sync marks list with window lines
function M.update_marks_list()
	local window = require('bufman.window')
	M.marks = table.map(function(v)
		if type(v) ~= 'string' then return end

		local filename = v
		local bufnr = nil

		local existing_mark = get_mark_by_name(filename, M.marks)
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
	M.marks = remove_duplicates(M.marks)
end

function M.get_ordered_bufids(should_remove_duplicates)
	M.synchronize_marks()
	local marks = M.marks
	if Util.nil_or_true(should_remove_duplicates) then --
		marks = remove_duplicates(M.marks)
	end
	return table.map(function(mark) return mark.bufnr end, marks)
end

return M
