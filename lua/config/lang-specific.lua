vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "c", "cpp" },
	callback = function()
		vim.bo.shiftwidth = 2
		vim.bo.tabstop = 2
		vim.bo.expandtab = false 
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "lua" },
	callback = function()
		vim.bo.shiftwidth = 2
		vim.bo.tabstop = 2
		vim.bo.expandtab = true 
	end,
})

