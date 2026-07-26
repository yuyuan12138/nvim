local M = {}

local enabled = true
local lint

local specs_by_ft = {
  python = {
    { name = "ruff", executable = "ruff" },
  },
  lua = {
    { name = "selene", executable = "selene" },
  },
  sh = {
    { name = "shellcheck", executable = "shellcheck" },
  },
  bash = {
    { name = "shellcheck", executable = "shellcheck" },
  },
  zsh = {
    { name = "shellcheck", executable = "shellcheck" },
  },
  go = {
    { name = "staticcheck", executable = "staticcheck" },
  },
  javascript = {
    { name = "eslint_d", executable = "eslint_d", config = "eslint" },
  },
  javascriptreact = {
    { name = "eslint_d", executable = "eslint_d", config = "eslint" },
  },
  typescript = {
    { name = "eslint_d", executable = "eslint_d", config = "eslint" },
  },
  typescriptreact = {
    { name = "eslint_d", executable = "eslint_d", config = "eslint" },
  },
  vue = {
    { name = "eslint_d", executable = "eslint_d", config = "eslint" },
  },
  css = {
    { name = "stylelint", executable = "stylelint", config = "stylelint" },
  },
  scss = {
    { name = "stylelint", executable = "stylelint", config = "stylelint" },
  },
  sass = {
    { name = "stylelint", executable = "stylelint", config = "stylelint" },
  },
  markdown = {
    { name = "markdownlint-cli2", executable = "markdownlint-cli2" },
  },
  dockerfile = {
    { name = "hadolint", executable = "hadolint" },
  },
  toml = {
    { name = "taplo", executable = "taplo" },
  },
  yaml = {
    { name = "yamllint", executable = "yamllint", optional = true },
  },
  rust = {
    { name = "clippy", executable = "cargo", manual_only = true },
  },
}

local config_markers = {
  eslint = {
    "eslint.config.js",
    "eslint.config.mjs",
    "eslint.config.cjs",
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.json",
    ".eslintrc.yaml",
    ".eslintrc.yml",
  },
  stylelint = {
    "stylelint.config.js",
    "stylelint.config.mjs",
    "stylelint.config.cjs",
    ".stylelintrc",
    ".stylelintrc.js",
    ".stylelintrc.cjs",
    ".stylelintrc.json",
    ".stylelintrc.yaml",
    ".stylelintrc.yml",
  },
}

local function dirname(path)
  if vim.fs and vim.fs.dirname then
    return vim.fs.dirname(path)
  end
  return vim.fn.fnamemodify(path, ":h")
end

local function find_upward(markers, start)
  if not markers then
    return true
  end

  if vim.fs and vim.fs.find then
    return vim.fs.find(markers, { path = start, upward = true })[1] ~= nil
  end

  local current = start
  while current and current ~= "" do
    for _, marker in ipairs(markers) do
      local candidate = current .. package.config:sub(1, 1) .. marker
      if vim.fn.filereadable(candidate) == 1 then
        return true
      end
    end
    local parent = vim.fn.fnamemodify(current, ":h")
    if parent == current then
      break
    end
    current = parent
  end
  return false
end

local function project_has_config(kind, bufnr)
  if not kind then
    return true
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  local start = name ~= "" and dirname(name) or vim.fn.getcwd()
  return find_upward(config_markers[kind], start)
end

local function available_linters(bufnr, include_manual)
  if not lint then
    return {}
  end

  local ft = vim.bo[bufnr].filetype
  local names = {}

  for _, spec in ipairs(specs_by_ft[ft] or {}) do
    local installed = vim.fn.executable(spec.executable) == 1
    local registered = lint.linters[spec.name] ~= nil
    local configured = project_has_config(spec.config, bufnr)

    local allowed = include_manual or not spec.manual_only
    if installed and registered and configured and allowed then
      table.insert(names, spec.name)
    end
  end

  return names
end

local function try_lint(bufnr, notify_missing, include_manual)
  if not enabled or not lint then
    return
  end

  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then
    return
  end

  local names = available_linters(bufnr, include_manual)
  if #names == 0 then
    if notify_missing then
      vim.notify("No configured linter is available for " .. vim.bo[bufnr].filetype, vim.log.levels.INFO)
    end
    return
  end

  lint.try_lint(names)
end

function M.setup()
  local loaded = pcall(vim.cmd.packadd, "nvim-lint")
  if not loaded then
    return
  end

  local ok
  ok, lint = pcall(require, "lint")
  if not ok then
    lint = nil
    return
  end

  local group = vim.api.nvim_create_augroup("PortableLint", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    callback = function(args)
      if vim.g.portable_lint_on_save ~= false then
        try_lint(args.buf, false, false)
      end
    end,
  })

  vim.api.nvim_create_user_command("Lint", function()
    try_lint(0, true, true)
  end, { desc = "Lint the current buffer" })

  vim.api.nvim_create_user_command("LintToggle", function()
    enabled = not enabled
    vim.notify("Lint on save: " .. (enabled and "enabled" or "disabled"))
  end, { desc = "Toggle linting for this Neovim session" })

  vim.keymap.set("n", "<leader>ll", function()
    try_lint(0, true, true)
  end, { silent = true, desc = "Lint current buffer" })

  vim.keymap.set("n", "<leader>lT", "<cmd>LintToggle<CR>", {
    silent = true,
    desc = "Toggle lint on save",
  })
end

function M.available_for_buffer(bufnr)
  return available_linters(bufnr or 0, true)
end

return M
