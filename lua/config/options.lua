local opt = vim.opt

opt.number = true
opt.hidden = true
opt.wildmenu = true
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.path:append('**')
opt.mouse = 'a'
opt.backup = false
opt.swapfile = false
opt.undofile = true
opt.clipboard = 'unnamed'
opt.visualbell = false

local undo_dir = vim.fn.stdpath('state') .. '/undo'
vim.fn.mkdir(undo_dir, 'p')
opt.undodir = undo_dir

vim.cmd('colorscheme default')
