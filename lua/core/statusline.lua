local M = {}

local mode_names = {
  n = "NORMAL",
  no = "O-PENDING",
  nov = "O-PENDING",
  noV = "O-PENDING",
  ["no\22"] = "O-PENDING",
  niI = "NORMAL",
  niR = "NORMAL",
  niV = "NORMAL",
  nt = "NORMAL",
  v = "VISUAL",
  V = "V-LINE",
  ["\22"] = "V-BLOCK",
  s = "SELECT",
  S = "S-LINE",
  ["\19"] = "S-BLOCK",
  i = "INSERT",
  ic = "INSERT",
  ix = "INSERT",
  R = "REPLACE",
  Rc = "REPLACE",
  Rx = "REPLACE",
  Rv = "V-REPLACE",
  c = "COMMAND",
  cv = "EX",
  ce = "EX",
  r = "PROMPT",
  rm = "MORE",
  ["r?"] = "CONFIRM",
  ["!"] = "SHELL",
  t = "TERMINAL",
}

local function escape_statusline(text)
  return tostring(text or ""):gsub("%%", "%%%%")
end

local function diagnostics()
  if not vim.diagnostic then
    return ""
  end

  local counts = { 0, 0, 0, 0 }
  for _, item in ipairs(vim.diagnostic.get(0)) do
    if item.severity and counts[item.severity] ~= nil then
      counts[item.severity] = counts[item.severity] + 1
    end
  end

  local parts = {}
  if counts[vim.diagnostic.severity.ERROR] > 0 then
    table.insert(parts, "E:" .. counts[vim.diagnostic.severity.ERROR])
  end
  if counts[vim.diagnostic.severity.WARN] > 0 then
    table.insert(parts, "W:" .. counts[vim.diagnostic.severity.WARN])
  end
  return table.concat(parts, " ")
end

local function lsp_names()
  if not vim.lsp then
    return ""
  end

  local clients = {}
  if vim.lsp.get_clients then
    clients = vim.lsp.get_clients({ bufnr = 0 })
  elseif vim.lsp.get_active_clients then
    clients = vim.lsp.get_active_clients({ bufnr = 0 })
  end

  local names = {}
  for _, client in ipairs(clients) do
    table.insert(names, client.name)
  end
  return table.concat(names, ",")
end

function _G.PortableStatusline()
  local mode = mode_names[vim.api.nvim_get_mode().mode] or "?"
  local file = vim.fn.expand("%:~:.")
  if file == "" then
    file = "[No Name]"
  end

  local modified = vim.bo.modified and " [+]" or ""
  local readonly = vim.bo.readonly and " [RO]" or ""
  local diag = diagnostics()
  local lsp = lsp_names()

  local left = " " .. mode .. " │ " .. escape_statusline(file) .. modified .. readonly
  local right_parts = {}
  if diag ~= "" then
    table.insert(right_parts, diag)
  end
  if lsp ~= "" then
    table.insert(right_parts, "LSP:" .. lsp)
  end
  table.insert(right_parts, "%l:%c")
  table.insert(right_parts, "%p%%")

  return left .. "%=" .. table.concat(right_parts, " │ ") .. " "
end

function M.setup()
  vim.o.statusline = "%!v:lua.PortableStatusline()"
end

return M
