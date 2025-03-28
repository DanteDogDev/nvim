local compile_tools = require("scripts.compile-tools")
---@diagnostic disable: param-type-mismatch, unused-local
local M = {}
M.setup = function(opts)
  opts = opts or {}
  M.job = require("scripts.compile-tools.async")
  M.match_id = {}
  M.active = false
  M.toggle = false
  M.job.setup()
  M.buf = 0
  M.win = 0
end

M.send_command = function(opts)
  if not M.active then M.open_terminal() end
  if not M.toggle then M.toggle_terminal() end
  M.job.buf = M.buf
  M.job.queue_cmd(opts)
end

M.open_terminal = function()
  if M.active then
    print("Terminal Already Initialized")
    return
  end
  M.last_win = vim.api.nvim_get_current_win()
  M.active = true
  M.toggle = true
  M.buf = vim.api.nvim_create_buf(false, true)
  M.win = vim.api.nvim_open_win(M.buf, true, {
    title = "Terminal",
    relative = "editor",
    width = vim.o.columns - 8,
    height = vim.o.lines - 8,
    col = 4,
    row = 2,
    border = "single",
    zindex = 25
  })
  vim.api.nvim_buf_set_keymap( M.buf, "n", "q", ":lua require('scripts.compile-tools').terminal.close_terminal()<CR>", { silent = true, noremap = true })
  vim.api.nvim_buf_set_keymap( M.buf, "n", "<C-c>", ":lua require('scripts.compile-tools').terminal.job.force_stop()<CR>", { silent = true, noremap = true })
  compile_tools.apply_syntax()
end

M.toggle_terminal = function()
  if not M.active then
    M.open_terminal()
    return
  end
  if M.toggle then
    vim.api.nvim_win_set_config(M.win, {hide = true})
    vim.api.nvim_set_current_win(M.last_win)
    M.toggle = false
  else
    M.last_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_config(M.win, {hide = false})
    vim.api.nvim_set_current_win(M.win)
    M.toggle = true
    vim.cmd("normal! G")
  end
end

M.clear_terminal = function()
  if not M.active then return end
  if not M.toggle then M.toggle_terminal() end
  vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, {})
end

M.close_terminal = function()
  if M.job.is_running then
    print("Process is still running ctrl-c to force stop")
    return
  end
  if M.win ~= nil then
    vim.api.nvim_win_close(M.win, true)
  end
  if M.buf ~= nil then
    vim.api.nvim_buf_delete(M.buf, { force = true, unload = true })
  end
  vim.api.nvim_set_current_win(M.last_win)
  M.buf = nil
  M.win = nil
  M.active = false
  M.toggle = false
  M.match_id = {}
end
return M
