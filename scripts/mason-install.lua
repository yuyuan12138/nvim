local root = assert(vim.env.PORTABLE_MASON_ROOT, "PORTABLE_MASON_ROOT is required")
local config_root = assert(vim.env.PORTABLE_CONFIG_ROOT, "PORTABLE_CONFIG_ROOT is required")

vim.opt.runtimepath:append(config_root .. "/pack/vendor/opt/mason.nvim")

local ok, mason = pcall(require, "mason")
if not ok then
  vim.api.nvim_err_writeln("Unable to load mason.nvim")
  vim.cmd("cquit 1")
  return
end

mason.setup({
  install_root_dir = root,
  PATH = "prepend",
  log_level = vim.log.levels.INFO,
  max_concurrent_installers = 4,
})

local registry = require("mason-registry")

local package_names = {
  -- LSP servers
  "lua-language-server",
  "clangd",
  "pyright",
  "rust-analyzer",
  "gopls",
  "bash-language-server",
  "typescript-language-server",
  "html-lsp",
  "css-lsp",
  "json-lsp",
  "yaml-language-server",
  "dockerfile-language-server",
  "taplo",
  "marksman",

  -- Linters
  "selene",
  "shellcheck",
  "staticcheck",
  "eslint_d",
  "stylelint",
  "markdownlint-cli2",
  "hadolint",
}

local refresh_ok, refresh_err = pcall(registry.refresh)
if not refresh_ok then
  vim.api.nvim_err_writeln("Mason registry refresh failed: " .. tostring(refresh_err))
  vim.cmd("cquit 1")
  return
end

local completed = 0
local failed = {}

local function finish(name, success, message)
  completed = completed + 1
  if not success then
    table.insert(failed, name .. (message and (": " .. tostring(message)) or ""))
  end
end

for _, name in ipairs(package_names) do
  local has_package, package = pcall(registry.get_package, name)
  if not has_package then
    finish(name, false, "package is not present in the registry")
  elseif package:is_installed() then
    print("Already installed: " .. name)
    finish(name, true)
  else
    print("Installing: " .. name)
    local started, install_err = pcall(function()
      package:install({}, function(success, err)
        finish(name, success == true and package:is_installed(), err)
      end)
    end)
    if not started then
      finish(name, false, install_err)
    end
  end
end

local done = vim.wait(30 * 60 * 1000, function()
  return completed >= #package_names
end, 200)

if not done then
  vim.api.nvim_err_writeln("Timed out while installing Mason packages")
  vim.cmd("cquit 1")
elseif #failed > 0 then
  vim.api.nvim_err_writeln("Some packages failed:\n  " .. table.concat(failed, "\n  "))
  vim.cmd("cquit 1")
else
  print("All portable language servers and linters were installed.")
  vim.cmd("qa")
end
