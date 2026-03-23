local M = {}

M.state = {
  buf = nil,
  chan = nil,
}

function M.open(height)
  if M.state.buf and vim.api.nvim_buf_is_valid(M.state.buf) then
    vim.cmd("botright " .. tostring(height) .. "split")
    vim.cmd("buffer " .. M.state.buf)
    M.state.chan = vim.b.terminal_job_id or M.state.chan
  else
    vim.cmd("botright " .. tostring(height) .. "split")
    vim.cmd("terminal")
    M.state.buf = vim.api.nvim_get_current_buf()
    M.state.chan = vim.b.terminal_job_id
  end

  vim.cmd("startinsert")
  return M.state.chan
end

function M.send(text)
  if not M.state.chan then
    return
  end
  vim.fn.chansend(M.state.chan, text)
end

return M
