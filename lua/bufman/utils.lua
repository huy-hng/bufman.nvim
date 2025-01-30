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
	local exists = vim.api.nvim_buf_is_valid(bufnr)
	return 1 == vim.fn.buflisted(bufnr) and exists and bufname ~= ''
end

return M
