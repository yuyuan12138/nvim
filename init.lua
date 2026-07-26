vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("core.toolchain").setup()
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.statusline").setup()
require("core.picker").setup()
require("core.lsp").setup()
require("core.lint").setup()
require("core.health").setup()

-- Use a built-in colorscheme so the config still looks good offline.
local ok = pcall(vim.cmd.colorscheme, "unokai")
if not ok then
  pcall(vim.cmd.colorscheme, "default")
end

-- Optional lualine. The native statusline above remains active if unavailable.
pcall(function()
  vim.cmd.packadd("lualine.nvim")
  local lualine = require("lualine")

  local function lsp_names()
    local clients = {}
    if vim.lsp then
      if vim.lsp.get_clients then
        clients = vim.lsp.get_clients({ bufnr = 0 })
      elseif vim.lsp.get_active_clients then
        clients = vim.lsp.get_active_clients({ bufnr = 0 })
      end
    end

    local names = {}
    for _, client in ipairs(clients) do
      table.insert(names, client.name)
    end
    return table.concat(names, ",")
  end

  lualine.setup({
    options = {
      icons_enabled = false,
      theme = "auto",
      component_separators = { left = "│", right = "│" },
      section_separators = { left = "", right = "" },
      globalstatus = true,
      disabled_filetypes = { statusline = { "dashboard" } },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = { { "filename", path = 1 } },
      lualine_x = { lsp_names, "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    inactive_sections = {
      lualine_c = { { "filename", path = 1 } },
      lualine_x = { "location" },
    },
  })
end)

-- Optional, untracked machine-specific overrides.
pcall(require, "local")
