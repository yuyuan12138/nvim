return {
  {
    dir = vim.fn.stdpath("config") .. "/lua/custom/cp_runner",
    name = "cp_runner",
    config = function()
      require("custom.cp_runner").setup({
        keymap = "<F5>",
        input_file = "in",
        output_file = nil, 
        split_height = 12,
      })
    end,
  },
}
