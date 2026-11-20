require("tuna").setup({
  compile_command = {
    cpp = {
      exec = "/opt/homebrew/bin/g++-15",
      args = {
        "-std=c++23",
        "-O2",
        "-Wall",
        "$(FNAME)",
        "-o",
        "$(FNOEXT)",
      },
    },
  },
  maximum_time = 3000,
  keymaps = {
    preset = "<leader>t",
  },
})

