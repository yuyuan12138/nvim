local opt = {noremap = true, silent = true}
vim.keymap.set('v', '<', '<gv', opt)
vim.keymap.set('v', '>', '>gv', opt)
vim.keymap.set('v', 'J', ":move '>+1<CR>gv-gv", opt)
vim.keymap.set('v', 'K', ":move '<-2<CR>gv-gv", opt)
vim.keymap.set('v', 'p', '"_dP', opt)
vim.keymap.set('i', 'jk', '<ESC>', opt)
vim.keymap.set('n', '<C-e>', '5<C-e>', opt)

-- Competitive Programming
vim.keymap.set('n', '<F5>', ":w | :!g++ sol.cpp -o sol -std=c++23 -Wall -O2<CR>", opt)
vim.keymap.set('n', '<F2>', ":e in<CR>", opt)
vim.keymap.set('n', '<F6>', ":!./sol < in <CR>", opt)
vim.api.nvim_create_user_command("Acm", function()
  local template_path = vim.fn.expand("~/.config/nvim/templates/cpp/cp.tpl")
  if vim.fn.filereadable(template_path) == 1 then
    vim.cmd("0r " .. template_path)
    vim.api.nvim_win_set_cursor(0, {8, 2})
  else
    print("Template file not found: " .. template_path)
  end
end, {})
