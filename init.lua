-- Neovim entry point. Keep startup wiring small; implementation lives in lua/.
require('config.options')
require('config.keymaps')
require('config.commands')

vim.cmd('filetype plugin indent on')
vim.cmd('syntax enable')

vim.cmd('colorscheme quiet')
