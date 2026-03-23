local M = {}

M.defaults = {
  keymap = "<F5>",
  split_height = 24,
  input_file = "in",
  output_file = nil, 
  include_dirs = {
    "/Users/yuyuan/cp/Wlib/misc",
  },
  compile_flags = table.concat({
    "-O2",
    "-Wall",
    "-Wextra",
    "-std=c++23",
    "-pedantic",
    "-Wshadow",
    "-Wformat=2",
    "-Wfloat-equal",
    "-Wconversion",
    "-Wlogical-op",
    "-Wshift-overflow=2",
    "-Wduplicated-cond",
    "-Wcast-qual",
    "-Wcast-align",
    "-D_GLIBCXX_DEBUG",
    "-fmax-errors=1",
    "-DLOCAL",
  }, " "),
}

return M
