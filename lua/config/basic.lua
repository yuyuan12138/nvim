-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
local function remove_bold(group)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
  if not ok or not hl then
    return
  end
  hl.bold = false
  vim.api.nvim_set_hl(0, group, hl)
end

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "unokai",
  callback = function()
    local groups = {
      "Normal",
      "NormalFloat",
      "Comment",
      "Constant",
      "Identifier",
      "Statement",
      "PreProc",
      "Type",
      "Special",
      "Underlined",
      "Todo",
      "Function",
      "Keyword",
      "Conditional",
      "Repeat",
      "Operator",
      "Exception",
      "Title",
      "Label",
      "StorageClass",
      "Structure",
      "Tag",
      "Delimiter",
      "Boolean",
      "Number",
      "String",
    }
    for _, group in ipairs(groups) do
      remove_bold(group)
    end
  end,
})

vim.cmd("colorscheme unokai")
vim.opt.termguicolors = true
vim.opt.fileformat = "unix"
vim.opt.fileformats = "unix,dos"
-- ================== basic setting ==================
vim.opt.compatible     = false       
vim.opt.syntax         = 'on'          
vim.opt.number         = true            
vim.opt.relativenumber = true    
vim.opt.tabstop        = 4              
vim.opt.shiftwidth     = 4      
vim.opt.expandtab      = true
vim.opt.autoindent  = true        
vim.opt.smartindent = true       
vim.opt.wrap = false             
vim.opt.backspace = 'indent,eol,start' 
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'
vim.opt.fileformats = 'unix,dos' 
vim.opt.colorcolumn = '120'
vim.opt.splitright = true

vim.opt.ignorecase = true       
vim.opt.smartcase = true         
vim.opt.hlsearch = true          
vim.opt.incsearch = true         

vim.opt.mouse = 'a'             
vim.opt.showcmd = true           
vim.opt.ruler = true             
vim.opt.laststatus = 2           

vim.opt.termguicolors = true

