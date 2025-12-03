local M = {
   "ThePrimeagen/harpoon",
   lazy = true,
   dependencies = "nvim-lua/plenary.nvim",
}

M.config = function() 
    require 'harpoon'.setup {

    }
end

return M
