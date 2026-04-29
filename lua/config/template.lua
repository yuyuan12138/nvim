local M = {}

M.dir = vim.fn.stdpath("config") .. "/templates"
M.dirs = {}
M.suffixes = { ".tpl" }

local function expand_path(p)
  return vim.fn.expand(p:gsub("^~", vim.env.HOME or "~"))
end

local function parse_yaml(path)
  if vim.fn.filereadable(path) == 0 then
    return nil
  end
  local lines = vim.fn.readfile(path)
  local paths = {}
  local suffixes = {}
  local current_key = nil
  for _, line in ipairs(lines) do
    if line:match("^%s*#") then
      -- skip comments
    elseif line:match("^paths%s*:") then
      current_key = "paths"
    elseif line:match("^suffixes%s*:") then
      current_key = "suffixes"
    elseif current_key then
      local item = line:match("^%s*-%s+(.+)")
      if item then
        local val = vim.trim(item)
        if current_key == "paths" then
          table.insert(paths, expand_path(val))
        elseif current_key == "suffixes" then
          table.insert(suffixes, val)
        end
      elseif not line:match("^%s*$") then
        current_key = nil
      end
    end
  end
  return { paths = paths, suffixes = suffixes }
end

local function load_config_from_yaml()
  local yaml_path = vim.fn.stdpath("config") .. "/template_paths.yaml"
  local cfg = parse_yaml(yaml_path)
  if cfg then
    if cfg.paths and #cfg.paths > 0 then
      M.dirs = cfg.paths
    else
      M.dirs = { M.dir }
    end
    if cfg.suffixes and #cfg.suffixes > 0 then
      M.suffixes = cfg.suffixes
    else
      M.suffixes = { ".tpl" }
    end
  else
    M.dirs = { M.dir }
    M.suffixes = { ".tpl" }
  end
end

local function has_template_suffix(name)
  for _, sfx in ipairs(M.suffixes) do
    if name:sub(-#sfx) == sfx then
      return sfx
    end
  end
  return nil
end

local function strip_suffix(name)
  for _, sfx in ipairs(M.suffixes) do
    if name:sub(-#sfx) == sfx then
      return name:sub(1, #name - #sfx)
    end
  end
  return name
end

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
  for _, dir in ipairs(M.dirs) do
    for _, sfx in ipairs(M.suffixes) do
      local path = dir .. "/" .. name .. sfx
      if vim.fn.filereadable(path) == 1 then
        local lines = vim.fn.readfile(path)
        insert_lines(lines)
        return
      end
    end
  end
  vim.notify("Template not found: " .. name, vim.log.levels.ERROR)
end

function M.list()
  local items = {}
  for _, dir in ipairs(M.dirs) do
    if vim.fn.isdirectory(dir) == 1 then
      local paths = vim.fs.find(function(name, path)
        return has_template_suffix(name) ~= nil
      end, {
        path = dir,
        type = "file",
        limit = math.huge,
        follow = false,
      })

      for _, path in ipairs(paths) do
        local rel = vim.fs.relpath(dir, path) or path
        table.insert(items, {
          path = path,
          name = strip_suffix(rel),
          dir = dir,
        })
      end
    end
  end

  table.sort(items, function(a, b) return a.name < b.name end)
  return items
end

function M.pick()
  local items = M.list()
  if vim.tbl_isempty(items) then
    vim.notify("No templates found in " .. table.concat(M.dirs, ", "), vim.log.levels.WARN)
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

function M.print_paths()
  if #M.dirs == 0 then
    print("No template search paths configured.")
    return
  end
  print("Search paths:")
  for i, dir in ipairs(M.dirs) do
    print(string.format("  %d. %s", i, dir))
  end
  print("Suffixes:")
  for i, sfx in ipairs(M.suffixes) do
    print(string.format("  %d. %s", i, sfx))
  end
end

function M.setup(opts)
  opts = opts or {}
  if opts.dir then
    M.dir = opts.dir
  end

  load_config_from_yaml()

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

  vim.api.nvim_create_user_command("TplPaths", function()
    M.print_paths()
  end, {
    desc = "Print all template search paths and suffixes",
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
