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

return M
