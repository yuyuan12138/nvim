local M = {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
}

function M.config() 
    require "lualine".setup {
        options = {
          theme = "auto",   
          section_separators = { left = "", right = "" },
          component_separators = { left = "", right = "" },
          globalstatus = true, -- 单一状态栏
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } }, -- 显示相对路径
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
    }
end

return M
