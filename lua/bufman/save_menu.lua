local list_manager = require('bufman.list_manager')

local M = {}

function M.decode_state(encoded)
	-- local state = vim.json.decode(encoded)
	local state = encoded
	if not state then return end
	---@type buffer_list
	local buffer_list = state.buffer_list

	-- list_manager.buffer_list = buffer_list
	-- list_manager.add_buffers()
	list_manager.sync_buffer_list()

	-- put all buffers in the order
	for i, buf in ipairs(buffer_list) do
		for j, b in ipairs(list_manager.buffer_list) do
			if b.filename == buf.filename then
				local val = table.remove(list_manager.buffer_list, j)
				table.insert(list_manager.buffer_list, i, val)
			end
		end
	end
end

function M.encode_state() --
	return vim.json.encode { buffer_list = list_manager.buffer_list }
end

return M
