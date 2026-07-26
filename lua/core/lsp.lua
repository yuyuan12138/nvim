local M = {}

local function joinpath(...)
  if vim.fs and vim.fs.joinpath then
    return vim.fs.joinpath(...)
  end
  return table.concat({ ... }, package.config:sub(1, 1))
end

local cpp_include_dir = joinpath(
  vim.fn.stdpath("config"),
  "library"
)

local function dirname(path)
  if vim.fs and vim.fs.dirname then
    return vim.fs.dirname(path)
  end
  return vim.fn.fnamemodify(path, ":h")
end

local function project_root(bufnr, markers)
  local name = vim.api.nvim_buf_get_name(bufnr)
  local start = name ~= "" and dirname(name) or vim.fn.getcwd()

  if vim.fs and vim.fs.find then
    local found = vim.fs.find(markers, { path = start, upward = true })[1]
    if found then
      return dirname(found)
    end
  else
    local current = start
    while current and current ~= "" do
      for _, marker in ipairs(markers) do
        local candidate = joinpath(current, marker)
        if vim.fn.filereadable(candidate) == 1 or vim.fn.isdirectory(candidate) == 1 then
          return current
        end
      end

      local parent = vim.fn.fnamemodify(current, ":h")
      if parent == current then
        break
      end
      current = parent
    end
  end

  return start
end

local function executable_cmd(candidates)
  for _, cmd in ipairs(candidates) do
    if vim.fn.executable(cmd[1]) == 1 then
      return cmd
    end
  end
end

local function format_buffer()
  if vim.lsp.buf.format then
    vim.lsp.buf.format({ async = true })
  elseif vim.lsp.buf.formatting then
    vim.lsp.buf.formatting()
  end
end

local function on_attach(_, bufnr)
  local function bufmap(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end

  vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

  bufmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
  bufmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
  bufmap("n", "gr", vim.lsp.buf.references, "Find references")
  bufmap("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
  bufmap("n", "K", vim.lsp.buf.hover, "Hover documentation")
  bufmap("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
  bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
  bufmap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
  bufmap("n", "<leader>lf", format_buffer, "Format buffer")
  bufmap("i", "<C-Space>", "<C-x><C-o>", "LSP completion")
end

local servers = {
  {
    name = "lua_ls",
    filetypes = { "lua" },
    commands = { { "lua-language-server" } },
    markers = { ".luarc.json", ".luarc.jsonc", ".git" },
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  {
    name = "clangd",
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    commands = {
      {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--header-insertion=iwyu",
      },
    },
    init_options = {
    fallbackFlags = {
        "-std=c++20",
        "-I" .. cpp_include_dir,
      },
    },
    markers = { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" },
  },
  {
    name = "pyright",
    filetypes = { "python" },
    commands = {
      { "basedpyright-langserver", "--stdio" },
      { "pyright-langserver", "--stdio" },
    },
    markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
  },
  {
    name = "rust_analyzer",
    filetypes = { "rust" },
    commands = { { "rust-analyzer" } },
    markers = { "Cargo.toml", "rust-project.json", ".git" },
  },
  {
    name = "gopls",
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    commands = { { "gopls" } },
    markers = { "go.work", "go.mod", ".git" },
    settings = {
      gopls = {
        analyses = { unusedparams = true, shadow = true },
        staticcheck = true,
        gofumpt = true,
      },
    },
  },
  {
    name = "bashls",
    filetypes = { "sh", "bash", "zsh" },
    commands = { { "bash-language-server", "start" } },
    markers = { ".git" },
  },
  {
    name = "ts_ls",
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    commands = { { "typescript-language-server", "--stdio" } },
    markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
  },
  {
    name = "html",
    filetypes = { "html" },
    commands = { { "vscode-html-language-server", "--stdio" } },
    markers = { "package.json", ".git" },
  },
  {
    name = "cssls",
    filetypes = { "css", "scss", "less" },
    commands = { { "vscode-css-language-server", "--stdio" } },
    markers = { "package.json", ".git" },
  },
  {
    name = "jsonls",
    filetypes = { "json", "jsonc" },
    commands = { { "vscode-json-language-server", "--stdio" } },
    markers = { "package.json", ".git" },
  },
  {
    name = "yamlls",
    filetypes = { "yaml", "yaml.docker-compose" },
    commands = { { "yaml-language-server", "--stdio" } },
    markers = { ".yamllint", ".git" },
  },
  {
    name = "dockerls",
    filetypes = { "dockerfile" },
    commands = { { "docker-langserver", "--stdio" } },
    markers = { "Dockerfile", ".git" },
  },
  {
    name = "taplo",
    filetypes = { "toml" },
    commands = { { "taplo", "lsp", "stdio" } },
    markers = { "taplo.toml", ".taplo.toml", "Cargo.toml", "pyproject.toml", ".git" },
  },
  {
    name = "marksman",
    filetypes = { "markdown", "markdown.mdx" },
    commands = { { "marksman", "server" } },
    markers = { ".marksman.toml", ".git" },
  },
}

local function configure_diagnostics()
  if not vim.diagnostic then
    return
  end

  vim.diagnostic.config({
    virtual_text = { spacing = 2, prefix = "●" },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = { border = "rounded", source = "if_many" },
  })
end

function M.setup()
  configure_diagnostics()

  if not vim.lsp or not vim.lsp.start then
    return
  end

  local group = vim.api.nvim_create_augroup("PortableLsp", { clear = true })

  for _, server in ipairs(servers) do
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = server.filetypes,
      callback = function(args)
        local cmd = executable_cmd(server.commands)
        if not cmd then
          return
        end

      vim.lsp.start({
        name = server.name,
        cmd = cmd,
        root_dir = project_root(args.buf, server.markers),
        settings = server.settings,
        init_options = server.init_options,
        on_attach = on_attach,
      })
      end,
    })
  end
end

return M
