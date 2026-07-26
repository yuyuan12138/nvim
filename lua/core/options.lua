local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.showmode = false

opt.mouse = "a"
opt.clipboard = ""
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.completeopt = { "menu", "menuone", "noselect" }

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true

opt.wrap = false
opt.breakindent = true
opt.scrolloff = 5
opt.sidescrolloff = 5
opt.splitbelow = true
opt.splitright = true

opt.updatetime = 250
opt.timeoutlen = 400
opt.laststatus = 3
opt.cmdheight = 1

-- Makes :find useful even when mini.pick is unavailable.
opt.path:append("**")
opt.wildmenu = true
opt.wildmode = { "longest:full", "full" }

-- Prefer ripgrep, but never require it.
if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --smart-case --hidden --glob !.git"
  opt.grepformat = "%f:%l:%c:%m"
end

opt.shortmess:append("I")
