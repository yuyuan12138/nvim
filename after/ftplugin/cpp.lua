-- C++ buffer-local settings and contest helpers.
vim.bo.expandtab = false
vim.bo.tabstop = 2
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2

vim.api.nvim_buf_create_user_command(0, 'CpCompile',
  '!g++ sol.cpp -O2 -Wall -std=c++23 -o sol', {})
vim.api.nvim_buf_create_user_command(0, 'CpRun', '!./sol', {})

vim.keymap.set('n', '<F5>', '<Cmd>CpCompile<CR>', {
  buffer = true,
  desc = 'Compile C++ solution',
})
vim.keymap.set('n', '<F6>', '<Cmd>CpRun<CR>', {
  buffer = true,
  desc = 'Run C++ solution',
})

vim.api.nvim_buf_create_user_command(0, 'CP', function(command)
  local name = command.args
  if name == '' then
    name = vim.fn.input('set name [sol.cpp]: ', 'sol.cpp')
  end
  if name == '' then
    vim.notify('Canceled', vim.log.levels.WARN)
    return
  end
  if not name:match('%.cpp$') then
    name = name .. '.cpp'
  end

  local path = vim.fn.fnamemodify(name, ':p')
  if vim.fn.filereadable(path) == 1 then
    if vim.fn.confirm('文件已存在，是否覆盖？', '&是\n&否', 2) ~= 1 then
      vim.notify('已取消，未修改文件。')
      return
    end
  end

  vim.cmd('edit! ' .. vim.fn.fnameescape(name))
  local template = {
    '#include <bits/stdc++.h>',
    '',
    'using namespace std;',
    '',
    'int main() {',
    '\tios::sync_with_stdio(false);',
    '\tcin.tie(nullptr);',
    '',
    '\treturn 0;',
    '}',
  }
  vim.api.nvim_buf_set_lines(0, 0, -1, false, template)
  vim.cmd('silent! write')
  vim.cmd('normal! gg')
  vim.api.nvim_win_set_cursor(0, { 7, 4 })
  vim.notify('已生成 ' .. name)
end, {
  nargs = '?',
  complete = 'file',
  desc = 'Create a C++ contest template',
})
