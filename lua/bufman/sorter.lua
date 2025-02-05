local M = {}

local function sort_by_path(buffer_list)
	table.sort(buffer_list, function (a, b)
		return a.filename < b.filename
	end)
end

local strategy_lookup = {
	path = sort_by_path
}

function M.sort(strategy, buffer_list)
	strategy_lookup[strategy](buffer_list)
end

function M.group(buffer_list)
	local buf_list = vim.tbl_map(function(bufnr)
		local bufname = vim.api.nvim_buf_get_name(bufnr)
		local path = vim.fn.fnamemodify(bufname, ':h')
		return {bufnr=bufnr, path=path}
	end, buffer_list)
	
	local groups = {}
	local group = {}
	local current_group_path

	for i, buf in ipairs(buf_list) do
		if buf.path ~= current_group_path and i ~= 1 then
			table.insert(groups, group)
			group = {}
		end

		table.insert(group, buf.bufnr)
		current_group_path = buf.path
	end

	if #group > 0 then
		table.insert(groups, group)
	end

	return groups
end

return M
