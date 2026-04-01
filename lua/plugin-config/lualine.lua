local M = {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
}

function M.config() 
    require "lualine".setup {
        options = {
          theme = "auto",   
          globalstatus = true, 
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } }, -- 显示相对路径
          lualine_x = { "encoding" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
    }
end

return M
