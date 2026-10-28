vim.api.nvim_create_user_command('MakeTags', '!ctags -R .', {
  desc = 'Generate tags for the current directory',
})
