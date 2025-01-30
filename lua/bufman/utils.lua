local M = {}

-- tbl_deep_extend does not work the way you would think
local function merge_table_impl(t1, t2)
	for k, v in pairs(t2) do
		if type(v) == 'table' then
			if type(t1[k]) == 'table' then
				merge_table_impl(t1[k], v)
			else
				t1[k] = v
			end
		else
			t1[k] = v
		end
	end
end

function M.merge_tables(...)
	local out = {}
	for i = 1, select('#', ...) do
		merge_table_impl(out, select(i, ...))
	end
	return out
end

function M.is_valid_buffer(bufnr)
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	local does_exist = vim.api.nvim_buf_is_valid(bufnr)
	local is_listed = 1 == vim.fn.buflisted(bufnr)

	local is_bufman_buffer = string.find(bufname, 'Bufman')
	if is_bufman_buffer then return true end

	return is_listed and does_exist and bufname ~= ''
end

return M
