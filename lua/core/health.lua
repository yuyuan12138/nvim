local M = {}

local function runtime_available(module)
  local ok = pcall(require, module)
  return ok and "yes" or "no"
end

local function executable(name)
  return vim.fn.executable(name) == 1 and "yes" or "no"
end

local function open_report(lines)
  vim.cmd("botright new")
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "checkhealth"
  vim.api.nvim_buf_set_name(buf, "PortableHealth")
end

local function add_tools(lines, title, names)
  table.insert(lines, title)
  table.insert(lines, string.rep("-", #title))
  for _, name in ipairs(names) do
    table.insert(lines, string.format("%-34s %s", name .. ":", executable(name)))
  end
  table.insert(lines, "")
end

function M.setup()
  vim.api.nvim_create_user_command("PortableHealth", function()
    local version = vim.version()
    local uname = vim.uv and vim.uv.os_uname() or (vim.loop and vim.loop.os_uname()) or {}
    local tools = vim.g.portable_tools_dir or "not configured"

    local lines = {
      "Portable Neovim health",
      "======================",
      "",
      string.format("Neovim: %d.%d.%d", version.major, version.minor, version.patch),
      "System: " .. (uname.sysname or "unknown") .. " " .. (uname.machine or ""),
      "Config: " .. vim.fn.stdpath("config"),
      "Tools:  " .. tools,
      "",
      "Optional plugins",
      "----------------",
      "mini.pick: " .. runtime_available("mini.pick"),
      "lualine:   " .. runtime_available("lualine"),
      "nvim-lint: " .. runtime_available("lint"),
      "",
    }

    add_tools(lines, "Bundled runtimes", { "node", "npm", "go" })
    add_tools(lines, "Search tools", { "rg", "fd", "git" })
    add_tools(lines, "Language servers", {
      "lua-language-server",
      "clangd",
      "pyright-langserver",
      "rust-analyzer",
      "gopls",
      "bash-language-server",
      "typescript-language-server",
      "vscode-html-language-server",
      "vscode-css-language-server",
      "vscode-json-language-server",
      "yaml-language-server",
      "docker-langserver",
      "taplo",
      "marksman",
    })
    add_tools(lines, "Linters", {
      "ruff",
      "selene",
      "shellcheck",
      "staticcheck",
      "eslint_d",
      "stylelint",
      "markdownlint-cli2",
      "hadolint",
      "taplo",
      "yamllint",
      "cargo",
    })

    table.insert(lines, "The config never downloads plugins or tools during startup.")
    table.insert(lines, "Use scripts/build-offline-bundle.sh on an online machine to create a full bundle.")

    open_report(lines)
  end, { desc = "Show portable config health" })
end

return M
