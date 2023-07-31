local utils = require('plugins.ui.heirline.buffer_manager.utils')
local filename = require('plugins.ui.heirline.buffer_manager.filename')

local M = {}
local MAX_DISPLAY_NAME_FOLDERS = 1
local MIN_AMOUNT_GROUPED_FILES = 2

local function marks_with_common_path(marks, path)
	local matching_marks = {}
	-- print('--------------------------------')
	for _, mark in ipairs(marks) do
		local name = filename.normalize_path(mark.filename)
		if string.starts(name, path) then
			-- print(name, 'MATCH')
			table.insert(matching_marks, mark)
		end
		-- print(name)
	end
	return matching_marks
end

local function group_mark(marks)
	local folders = filename.get_path_folders(marks[1].filename)

	local common_path = {}
	local matching_marks = { marks[1] }
	for _, folder in ipairs(folders) do
		local path = string.join(common_path, '/') .. folder
		local match = marks_with_common_path(marks, path)
		if #match < MIN_AMOUNT_GROUPED_FILES then break end
		matching_marks = match
		table.insert(common_path, folder)
	end

	return common_path, matching_marks
end

local function remove_matching_marks(marks, matching_marks)
	for _, match in ipairs(matching_marks) do
		for i, mark in ipairs(marks) do
			if mark.bufnr == match.bufnr then
				table.remove(marks, i)
				break
			end
		end
	end
	return marks
end

---@param marks mark[]
---@return { common_path: string[], marks: mark[] }[]
function M.group_marks(marks)
	local to_be_grouped = utils.deep_copy(marks)
	local groups = {}
	local safety_counter = 0
	while #to_be_grouped > 0 or safety_counter > 100 do
		local common_path, matching_marks = group_mark(to_be_grouped)
		remove_matching_marks(to_be_grouped, matching_marks)
		table.insert(groups, { common_path = common_path, marks = matching_marks })
		safety_counter = safety_counter + 1
	end
	return groups
end

function M.group_by_text(lines)
	local prev_path
	local groups = {}
	for i, file in ipairs(lines) do
		local path, _ = filename.get_path_folders(file, 0)

		local common_path = {}
		local matching_marks = { lines[1] }
		for _, folder in ipairs(path) do
			local path_string = string.join(common_path, '/') .. folder
			table.insert(common_path, folder)

			table.remove(lines, i)
		end
	end
end

return M