local M = {}

local function joinpath(...)
  if vim.fs and vim.fs.joinpath then
    return vim.fs.joinpath(...)
  end
  return table.concat({ ... }, package.config:sub(1, 1))
end

local cpp_include_dir = joinpath(
  vim.fn.stdpath("config"),
  "Wlib"
)

local clangd_markers = {
  "compile_commands.json",
  "compile_flags.txt",
  ".clangd",
  "CMakeLists.txt",
  "Makefile",
  "makefile",
  "GNUmakefile",
  ".git",
}

local makefile_markers = { "Makefile", "makefile", "GNUmakefile" }

local function extend_string_list(target, values)
  if type(values) ~= "table" then
    return
  end

  for _, value in ipairs(values) do
    if type(value) == "string" and value ~= "" then
      table.insert(target, value)
    end
  end
end

local function clangd_fallback_flags()
  local flags = {
    "-std=c++20",
    "-I" .. cpp_include_dir,
  }

  extend_string_list(flags, vim.g.portable_clangd_fallback_flags)
  return flags
end

local function dirname(path)
  if vim.fs and vim.fs.dirname then
    return vim.fs.dirname(path)
  end
  return vim.fn.fnamemodify(path, ":h")
end

local function is_file(path)
  return vim.fn.filereadable(path) == 1
end

local function is_directory(path)
  return vim.fn.isdirectory(path) == 1
end

local function path_exists(path)
  return is_file(path) or is_directory(path)
end

local function normalize_path(path)
  if not path or path == "" then
    return nil
  end

  local normalized = vim.fn.fnamemodify(path, ":p")
  return normalized:gsub(package.config:sub(1, 1) .. "$", "")
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

local function command_label(cmd)
  return table.concat(cmd, " ")
end

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO)
end

local function output_excerpt(stdout, stderr)
  local lines = {}

  extend_string_list(lines, stderr)
  extend_string_list(lines, stdout)

  if #lines == 0 then
    return ""
  end

  local limit = math.min(#lines, 10)
  local excerpt = {}
  for i = 1, limit do
    table.insert(excerpt, lines[i])
  end
  if #lines > limit then
    table.insert(excerpt, "...")
  end

  return "\n" .. table.concat(excerpt, "\n")
end

local function run_job(cmd, opts)
  local stdout = {}
  local stderr = {}

  local job = vim.fn.jobstart(cmd, {
    cwd = opts.cwd,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      extend_string_list(stdout, data)
    end,
    on_stderr = function(_, data)
      extend_string_list(stderr, data)
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        opts.on_exit(code, stdout, stderr)
      end)
    end,
  })

  if job <= 0 then
    notify("Failed to start: " .. command_label(cmd), vim.log.levels.ERROR)
    return false
  end

  return true
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
    init_options = function()
      return {
        fallbackFlags = clangd_fallback_flags(),
      }
    end,
    markers = clangd_markers,
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

local function find_server(name)
  for _, server in ipairs(servers) do
    if server.name == name then
      return server
    end
  end
end

local function server_supports_filetype(server, filetype)
  for _, supported in ipairs(server.filetypes or {}) do
    if supported == filetype then
      return true
    end
  end

  return false
end

local function start_lsp_server(server, bufnr, root_dir)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local cmd = executable_cmd(server.commands)
  if not cmd then
    return
  end

  local init_options = server.init_options
  if type(init_options) == "function" then
    init_options = init_options(bufnr)
  end

  vim.api.nvim_buf_call(bufnr, function()
    vim.lsp.start({
      name = server.name,
      cmd = cmd,
      root_dir = root_dir or project_root(bufnr, server.markers),
      settings = server.settings,
      init_options = init_options,
      on_attach = on_attach,
    })
  end)
end

local function lsp_clients()
  if vim.lsp.get_clients then
    return vim.lsp.get_clients()
  end
  if vim.lsp.get_active_clients then
    return vim.lsp.get_active_clients()
  end
  return {}
end

local function clangd_client_root(client)
  if client.config and client.config.root_dir then
    return client.config.root_dir
  end
  return client.root_dir
end

local function restart_clangd(bufnr, root)
  local server = find_server("clangd")
  if not server or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local target_root = normalize_path(root)
  local stopped = false

  for _, client in ipairs(lsp_clients()) do
    if client.name == "clangd" and normalize_path(clangd_client_root(client)) == target_root then
      client.stop(true)
      stopped = true
    end
  end

  local function start()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    if not server_supports_filetype(server, vim.bo[bufnr].filetype) then
      return
    end
    start_lsp_server(server, bufnr, root)
  end

  if stopped then
    vim.defer_fn(start, 250)
  else
    start()
  end
end

local function find_makefile(root)
  for _, name in ipairs(makefile_markers) do
    local candidate = joinpath(root, name)
    if is_file(candidate) then
      return candidate
    end
  end
end

local function link_or_copy_file(source, dest)
  local uv = vim.uv or vim.loop
  if uv and uv.fs_symlink then
    local ok, result = pcall(uv.fs_symlink, source, dest)
    if ok and result then
      return true, "Linked " .. dest .. " to " .. source
    end
  end

  local read_ok, lines = pcall(vim.fn.readfile, source, "b")
  if not read_ok then
    return false, "Could not read " .. source
  end

  local write_ok, result = pcall(vim.fn.writefile, lines, dest, "b")
  if write_ok and result == 0 then
    return true, "Copied " .. source .. " to " .. dest
  end

  return false, "Could not write " .. dest
end

local function sync_compile_commands_to_root(root, source, force)
  local dest = joinpath(root, "compile_commands.json")

  if normalize_path(source) == normalize_path(dest) then
    return true, "Generated " .. dest
  end

  if is_directory(dest) then
    return false, dest .. " exists as a directory"
  end

  if path_exists(dest) then
    local uv = vim.uv or vim.loop
    local stat = uv and uv.fs_lstat and uv.fs_lstat(dest) or nil
    local replace = force or (stat and stat.type == "link")

    if not replace then
      return true, "Generated " .. source .. "; kept existing " .. dest
    end

    local removed, err = os.remove(dest)
    if not removed then
      return false, "Could not replace " .. dest .. ": " .. (err or "unknown error")
    end
  end

  return link_or_copy_file(source, dest)
end

local function finish_compile_commands(bufnr, root, source, force)
  if not is_file(source) then
    notify("Command finished, but did not create " .. source, vim.log.levels.ERROR)
    return
  end

  local ok, message = sync_compile_commands_to_root(root, source, force)
  if not ok then
    notify(message, vim.log.levels.ERROR)
    return
  end

  notify(message .. "; restarting clangd")
  restart_clangd(bufnr, root)
end

local function generate_cmake_compile_commands(bufnr, root, force, extra_args)
  if vim.fn.executable("cmake") ~= 1 then
    notify("CMakeLists.txt found, but cmake is not available", vim.log.levels.ERROR)
    return
  end

  local build_dir = joinpath(root, "build")
  local cmd = {
    "cmake",
    "-S",
    root,
    "-B",
    build_dir,
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
  }
  extend_string_list(cmd, extra_args)

  notify("Running " .. command_label(cmd))
  run_job(cmd, {
    cwd = root,
    on_exit = function(code, stdout, stderr)
      if code ~= 0 then
        notify("cmake failed with exit code " .. code .. output_excerpt(stdout, stderr), vim.log.levels.ERROR)
        return
      end

      finish_compile_commands(bufnr, root, joinpath(build_dir, "compile_commands.json"), force)
    end,
  })
end

local function generate_make_compile_commands(bufnr, root, extra_args)
  if vim.fn.executable("bear") ~= 1 then
    notify("Makefile found, but bear is not available to capture compile commands", vim.log.levels.ERROR)
    return
  end

  local cmd = { "bear", "--", "make" }
  extend_string_list(cmd, extra_args)

  notify("Running " .. command_label(cmd))
  run_job(cmd, {
    cwd = root,
    on_exit = function(code, stdout, stderr)
      if code ~= 0 then
        notify("bear failed with exit code " .. code .. output_excerpt(stdout, stderr), vim.log.levels.ERROR)
        return
      end

      finish_compile_commands(bufnr, root, joinpath(root, "compile_commands.json"), false)
    end,
  })
end

local function generate_compile_commands(opts)
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local root = project_root(bufnr, clangd_markers)

  if is_file(joinpath(root, "CMakeLists.txt")) then
    generate_cmake_compile_commands(bufnr, root, opts.bang, opts.fargs)
    return
  end

  if find_makefile(root) then
    generate_make_compile_commands(bufnr, root, opts.fargs)
    return
  end

  if is_file(joinpath(root, "compile_commands.json")) or is_file(joinpath(root, "compile_flags.txt")) then
    notify("clangd compile flags already exist in " .. root .. "; restarting clangd")
    restart_clangd(bufnr, root)
    return
  end

  notify("No CMakeLists.txt, Makefile, compile_commands.json, or compile_flags.txt found from " .. root, vim.log.levels.WARN)
end

local function create_clangd_commands()
  vim.api.nvim_create_user_command("ClangdGenCompileCommands", function(opts)
    generate_compile_commands({
      bufnr = vim.api.nvim_get_current_buf(),
      bang = opts.bang,
      fargs = opts.fargs,
    })
  end, {
    bang = true,
    nargs = "*",
    desc = "Generate compile_commands.json for clangd from CMake or Make",
  })
end

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

  create_clangd_commands()

  local group = vim.api.nvim_create_augroup("PortableLsp", { clear = true })

  for _, server in ipairs(servers) do
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = server.filetypes,
      callback = function(args)
        start_lsp_server(server, args.buf)
      end,
    })
  end
end

return M
