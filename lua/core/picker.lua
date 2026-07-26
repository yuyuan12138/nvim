local M = {}

local map = vim.keymap.set

local function shell_command(args)
  local escaped = {}
  for _, arg in ipairs(args) do
    table.insert(escaped, vim.fn.shellescape(arg))
  end
  return table.concat(escaped, " ")
end

local function systemlist(args)
  return vim.fn.systemlist(shell_command(args))
end

local function git_root_exists()
  if vim.fn.executable("git") ~= 1 then
    return false
  end
  vim.fn.system(shell_command({ "git", "rev-parse", "--is-inside-work-tree" }))
  return vim.v.shell_error == 0
end

local function fallback_files()
  local files
  if vim.fn.executable("rg") == 1 then
    files = systemlist({ "rg", "--files", "--hidden", "-g", "!.git" })
  elseif vim.fn.executable("fd") == 1 then
    files = systemlist({ "fd", "--type", "f", "--hidden", "--exclude", ".git" })
  elseif git_root_exists() then
    files = systemlist({ "git", "ls-files", "--cached", "--others", "--exclude-standard" })
  else
    files = vim.fn.glob("**/*", false, true)
    files = vim.tbl_filter(function(path)
      return vim.fn.filereadable(path) == 1 and not path:find("/.git/", 1, true)
    end, files)
  end

  vim.ui.select(files, { prompt = "Files" }, function(choice)
    if choice then
      vim.cmd.edit(vim.fn.fnameescape(choice))
    end
  end)
end

local function fallback_buffers()
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  local choices = {}
  local lookup = {}

  for _, buffer in ipairs(buffers) do
    local name = buffer.name ~= "" and vim.fn.fnamemodify(buffer.name, ":~:.") or "[No Name]"
    local label = string.format("%d  %s", buffer.bufnr, name)
    table.insert(choices, label)
    lookup[label] = buffer.bufnr
  end

  vim.ui.select(choices, { prompt = "Buffers" }, function(choice)
    if choice then
      vim.api.nvim_set_current_buf(lookup[choice])
    end
  end)
end

local function fallback_grep()
  local pattern = vim.fn.input("Grep pattern: ")
  if pattern == "" then
    return
  end

  if vim.fn.executable("rg") == 1 then
    vim.cmd("silent grep! " .. vim.fn.shellescape(pattern))
  else
    local escaped = vim.fn.escape(pattern, "/\\")
    vim.cmd("silent vimgrep /" .. escaped .. "/gj **/*")
  end

  if #vim.fn.getqflist() > 0 then
    vim.cmd.copen()
  else
    vim.notify("No matches", vim.log.levels.INFO)
  end
end

local function fallback_help()
  local topic = vim.fn.input("Help topic: ")
  if topic ~= "" then
    vim.cmd.help(topic)
  end
end

local function fallback_recent()
  local files = vim.tbl_filter(function(path)
    return vim.fn.filereadable(path) == 1
  end, vim.v.oldfiles or {})

  vim.ui.select(files, { prompt = "Recent files" }, function(choice)
    if choice then
      vim.cmd.edit(vim.fn.fnameescape(choice))
    end
  end)
end

local function setup_fallback_maps()
  map("n", "<leader>ff", fallback_files, { desc = "Find files" })
  map("n", "<leader>fg", fallback_grep, { desc = "Grep text" })
  map("n", "<leader>fb", fallback_buffers, { desc = "Find buffers" })
  map("n", "<leader>fh", fallback_help, { desc = "Find help" })
  map("n", "<leader>fr", fallback_recent, { desc = "Recent files" })
end

function M.setup()
  local loaded = pcall(vim.cmd.packadd, "mini.pick")
  if not loaded then
    setup_fallback_maps()
    return
  end

  local ok, pick = pcall(require, "mini.pick")
  if not ok then
    setup_fallback_maps()
    return
  end

  local win_config = function()
    local height = math.max(10, math.floor(0.60 * vim.o.lines))
    local width = math.max(50, math.floor(0.70 * vim.o.columns))
    return {
      border = "rounded",
      height = height,
      width = width,
      row = math.floor(0.5 * (vim.o.lines - height)),
      col = math.floor(0.5 * (vim.o.columns - width)),
    }
  end

  pick.setup({
    options = { use_cache = true },
    source = { show = pick.default_show },
    window = { config = win_config },
  })

  map("n", "<leader>ff", function()
    pick.builtin.files()
  end, { desc = "Find files" })

  map("n", "<leader>fg", function()
    if vim.fn.executable("rg") == 1 or git_root_exists() then
      pick.builtin.grep_live()
    else
      fallback_grep()
    end
  end, { desc = "Live grep" })

  map("n", "<leader>fb", function()
    pick.builtin.buffers()
  end, { desc = "Find buffers" })

  map("n", "<leader>fh", function()
    pick.builtin.help()
  end, { desc = "Find help" })

  map("n", "<leader>fr", fallback_recent, { desc = "Recent files" })
end

return M
