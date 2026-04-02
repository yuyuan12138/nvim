local M = {}

M.dir = vim.fn.stdpath("config") .. "/templates"

local function is_empty_buffer()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  return #lines == 1 and lines[1] == ""
end

local function render_template(lines)
  local filename = vim.fn.expand("%:t")
  local basename = vim.fn.expand("%:t:r")
  local created_at = os.date("%Y-%m-%d %H:%M:%S")
  local author = "Yuyuan"

  local out = {}
  for _, line in ipairs(lines) do
    line = line:gsub("{{AUTHOR}}", author)
    line = line:gsub("{{CREATED_AT}}", created_at)
    table.insert(out, line)
  end
  return out
end

local function insert_lines(lines)
  lines = render_template(lines)

  if is_empty_buffer() then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  else
    local row = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(0, row, row, false, lines)
  end
end

function M.apply(name)
  local path = M.dir .. "/" .. name .. ".tpl"
  if vim.fn.filereadable(path) == 0 then
    vim.notify("Template not found: " .. path, vim.log.levels.ERROR)
    return
  end

  local lines = vim.fn.readfile(path)
  insert_lines(lines)
end

function M.list()
  local paths = vim.fs.find(function(name, path)
    return name:sub(-4) == ".tpl"
  end, {
    path = M.dir,
    type = "file",
    limit = math.huge,
    follow = false, -- set true if you want to follow symlinks
  })

  table.sort(paths)

  local items = {}
  for _, path in ipairs(paths) do
    local rel = vim.fs.relpath(M.dir, path) or path
    table.insert(items, {
      path = path,
      name = rel:gsub("%.tpl$", ""),
    })
  end
  return items 
end

function M.pick()
  local items = M.list()
  if vim.tbl_isempty(items) then
    vim.notify("No templates found in " .. M.dir, vim.log.levels.WARN)
    return
  end

  vim.ui.select(items, {
    prompt = "Choose template",
    format_item = function(item)
      return item.name
    end,
  }, function(item)
    if not item then
      return
    end
    local lines = vim.fn.readfile(item.path)
    insert_lines(lines)
  end)
end

function M.setup(opts)
  opts = opts or {}
  if opts.dir then
    M.dir = opts.dir
  end

  vim.api.nvim_create_user_command("Tpl", function(cmd)
    if cmd.args ~= "" then
      M.apply(cmd.args)
    else
      M.pick()
    end
  end, {
    nargs = "?",
    desc = "Insert a template",
    complete = function(ArgLead)
      local names = {}
      for _, item in ipairs(M.list()) do
        if item.name:find("^" .. vim.pesc(ArgLead)) then
          table.insert(names, item.name)
        end
      end
      return names
    end,
  })

  local group = vim.api.nvim_create_augroup("MyTemplates", { clear = true })

  local auto = opts.auto_by_extension or {}
  for pattern, template_name in pairs(auto) do
    vim.api.nvim_create_autocmd("BufNewFile", {
      group = group,
      pattern = pattern,
      callback = function()
        if is_empty_buffer() then
          M.apply(template_name)
        end
      end,
    })
  end
end
return M    

