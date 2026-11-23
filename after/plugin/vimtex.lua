-- VimTeX configuration

vim.g.vimtex_view_method = "skim"
vim.g.vimtex_compiler_method = "latexmk"

vim.g.vimtex_compiler_latexmk = {
	options = {
		"-pdf",
		"-interaction=nonstopmode",
		"-synctex=1",
		"-file-line-error",
	},
}
