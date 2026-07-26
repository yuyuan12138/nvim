local M = {}

local function joinpath(...)
  if vim.fs and vim.fs.joinpath then
    return vim.fs.joinpath(...)
  end
  return table.concat({ ... }, package.config:sub(1, 1))
end

local function prepend_path(path)
  if vim.fn.isdirectory(path) ~= 1 then
    return
  end

  local separator = package.config:sub(1, 1) == "\\" and ";" or ":"
  local current = vim.env.PATH or ""
  vim.env.PATH = path .. (current ~= "" and (separator .. current) or "")
end

function M.setup()
  local config = vim.fn.stdpath("config")
  local tools = joinpath(config, "tools")
  local node = joinpath(tools, "node")
  local go = joinpath(tools, "go")
  local mason = joinpath(tools, "mason")
  local ruff = joinpath(tools, "ruff")

  -- The final order is Ruff, Go, Node, Mason, then the host PATH.
  -- Mason's wrapper scripts can therefore resolve the matching bundled runtimes offline.
  prepend_path(joinpath(mason, "bin"))
  prepend_path(joinpath(node, "bin"))
  prepend_path(joinpath(go, "bin"))
  prepend_path(joinpath(ruff, "bin"))

  if vim.fn.isdirectory(go) == 1 then
    vim.env.GOROOT = go
  end

  vim.g.portable_tools_dir = tools
  vim.g.portable_node_dir = node
  vim.g.portable_go_dir = go
  vim.g.portable_mason_dir = mason
  vim.g.portable_ruff_dir = ruff
end

return M
