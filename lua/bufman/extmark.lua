local M = {}
local buffer = require('bufman.buffer')
local filename = require('bufman.filename')


local ns = vim.api.nvim_create_namespace('Bufman')


function M.set_extmark(bufnr, row, content, extra_opts)
	if not vim.api.nvim_buf_is_valid(bufnr) then return end

	local mark_opts = {
		virt_text = content,
		virt_text_pos = 'overlay',
		hl_mode = 'combine',

		virt_lines_leftcol = true,
		virt_lines_above = true,
		strict = false,
	}
	mark_opts = vim.tbl_extend('force', mark_opts, extra_opts or {})

	vim.api.nvim_buf_set_extmark(bufnr, ns, row, 0, mark_opts)
end

function M.set_extmarks(bufman_bufnr, buffer_list)
	for i, bufnr in pairs(buffer_list) do
		local bufname = vim.api.nvim_buf_get_name(bufnr)
		local fname = filename.get_filename(bufname)
		M.set_extmark(bufman_bufnr, i - 1, { { tostring(bufnr) .. ' ' }, { fname } })
	end

end

return M
