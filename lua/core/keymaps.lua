local map = vim.keymap.set
local silent = { silent = true }

map("n", "<Esc>", "<cmd>nohlsearch<CR>", silent)
map("n", "<leader>w", "<cmd>write<CR>", { silent = true, desc = "Write file" })
map("n", "<leader>q", "<cmd>quit<CR>", { silent = true, desc = "Quit window" })
map("n", "<leader>Q", "<cmd>qa<CR>", { silent = true, desc = "Quit Neovim" })
map("n", "<leader>e", "<cmd>Explore<CR>", { silent = true, desc = "File explorer" })

map("n", "<C-h>", "<C-w>h", silent)
map("n", "<C-j>", "<C-w>j", silent)
map("n", "<C-k>", "<C-w>k", silent)
map("n", "<C-l>", "<C-w>l", silent)

map("n", "<C-Up>", "<cmd>resize +2<CR>", silent)
map("n", "<C-Down>", "<cmd>resize -2<CR>", silent)
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", silent)
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", silent)

map("v", "<", "<gv", silent)
map("v", ">", ">gv", silent)
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Leave terminal mode" })

map("n", "[d", function()
  if vim.diagnostic.goto_prev then
    vim.diagnostic.goto_prev({ float = true })
  end
end, { desc = "Previous diagnostic" })

map("n", "]d", function()
  if vim.diagnostic.goto_next then
    vim.diagnostic.goto_next({ float = true })
  end
end, { desc = "Next diagnostic" })

map("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Diagnostics list" })
