local M = {}


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

return M
