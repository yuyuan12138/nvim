local M = {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
}
M.config = function() 
    require('nvim-treesitter.configs').setup {
        ensure_installed = { "c", "cpp", "lua", "vim", "bash", "json", "markdown" },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
    }
end

return M
