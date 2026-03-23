local term = require("custom.cp_runner.terminal")

local M = {}

local function is_windows()
  return vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
end

function M.compile_and_run(opts)
  if vim.bo.filetype ~= "cpp" then
    vim.notify("当前文件不是 cpp", vim.log.levels.WARN)
    return
  end

  vim.cmd("write")

  local dir = vim.fn.expand("%:p:h")
  local file = vim.fn.expand("%:t")
  local stem = vim.fn.expand("%:t:r")

  local exe
  if is_windows() then
    exe = stem .. ".exe"
  else
    exe = stem
  end
  local include_flags = {}
  for _, dir in ipairs(opts.include_dirs or {}) do
    table.insert(include_flags, "-I" .. vim.fn.shellescape(dir))
  end
  local compile_cmd = string.format(
    "g++ %s -o %s %s %s",
    vim.fn.shellescape(file),
    vim.fn.shellescape(exe),
    table.concat(include_flags, " "),
    opts.compile_flags
  )

  local run_cmd
  if is_windows() then
    run_cmd = string.format('"%s" < %s', exe, opts.input_file)
  else
    run_cmd = string.format("./%s < %s", vim.fn.shellescape(exe), vim.fn.shellescape(opts.input_file))
  end

  if opts.output_file and opts.output_file ~= "" then
    run_cmd = run_cmd .. " > " .. vim.fn.shellescape(opts.output_file)
  end

  local full_cmd = string.format(
    "cd %s && %s && %s\r",
    vim.fn.shellescape(dir),
    compile_cmd,
    run_cmd
  )

  term.open(opts.split_height)
  term.send(full_cmd)
end

return M
