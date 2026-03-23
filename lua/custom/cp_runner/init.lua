local config = require("custom.cp_runner.config")
local runner = require("custom.cp_runner.runner")

local M = {}

M.options = vim.deepcopy(config.defaults)

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, config.defaults, opts or {})

  vim.keymap.set("n", M.options.keymap, function()
    runner.compile_and_run(M.options)
  end, {
    noremap = true,
    silent = true,
    desc = "Compile and run cpp with input file",
  })

  vim.api.nvim_create_user_command("CpRun", function()
    runner.compile_and_run(M.options)
  end, {})
end

return M
