local list_manager = require('bufman.list_manager')

local M = {}

function M.decode_state(encoded)
	local state = vim.json.decode(encoded)
	if not state then return end
	---@type buffer_list
	local buffer_list = state.buffer_list

	-- P(buffer_list)
	list_manager.buffer_list = buffer_list
	list_manager.add_buffers()

	for i, buf in ipairs(buffer_list) do
		for j, b in ipairs(list_manager.buffer_list) do
			if b.filename == buf.filename then
				local val = table.remove(list_manager.buffer_list, j)
				table.insert(list_manager.buffer_list, i, val)
			end
		end
	end
	-- P(list_manager.buffer_list)
end

function M.encode_state()
	local state = {
		buffer_list = list_manager.buffer_list,
	}
	return vim.json.encode(state)
end

return M
