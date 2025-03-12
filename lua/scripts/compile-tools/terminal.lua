---@diagnostic disable: param-type-mismatch, unused-local
local M = {}
M.setup = function(opts)
  opts = opts or {}
  M.buf = nil
  M.win = nil
  M.job = nil ---@type Job
  M.isRunning = false ---@type boolean
  M.env = opts.env or {}
  M.commandQueue = {}
end

M.open_terminal = function()
  if M.buf ~= nil or M.win ~= nil then
    print("Terminal Already Open")
    return
  end
  M.buf = vim.api.nvim_create_buf(false, true)
  M.win = vim.api.nvim_open_win(M.buf, true, {
    title = "Terminal",
    relative = "editor",
    width = vim.o.columns - 16,
    height = vim.o.lines - 16,
    col = 8,
    row = 4,
    border = "single",
  })
  M.isRunning = false
  vim.api.nvim_buf_set_keymap( M.buf, "n", "q", ":lua require('scripts.compile-tools').terminal.close_terminal()<CR>", { silent = true, noremap = true })
  vim.api.nvim_buf_set_keymap( M.buf, "n", "<C-c>", ":lua require('scripts.compile-tools').terminal.force_stop()<CR>", { silent = true, noremap = true })
end

M.close_terminal = function()
  if M.isRunning then
    print("Process is still running ctrl-c to force stop")
    return
  end
  if M.win ~= nil then
    vim.api.nvim_win_close(M.win, true)
  end
  if M.buf ~= nil then
    vim.api.nvim_buf_delete(M.buf, { force = true, unload = true })
  end
  M.buf = nil
  M.win = nil
end

M.force_stop = function()
  print("control c")
  if not M.isRunning or M.job == nil then return end
  print("Job forcefully stopped with exit code -1 and signal SIGTERM.")
  M.job:shutdown(-1, 'SIGTERM')
  M.job = nil
end

---@param err string
---@param data string
---@param job Job
local function on_stdout(err, data, job)
  vim.schedule(function()
    if err then vim.fn.appendbufline(M.buf, "$", "Error: " .. err)end
    if data then vim.fn.appendbufline(M.buf, "$", data)end
    vim.cmd('normal! G')
  end)
end

---@param err string
---@param data string
---@param job Job
local function on_stderr(err, data, job)
  vim.schedule(function()
    if err then vim.fn.appendbufline(M.buf, "$", "Error: " .. err)end
    if data then vim.fn.appendbufline(M.buf, "$", data)end
    vim.cmd('normal! G')
  end)
end

---@param job Job
local function on_start(job)
  M.isRunning = true
  vim.schedule(function()
    vim.fn.appendbufline(M.buf, "$", M.job.cwd)
    vim.fn.appendbufline(M.buf, "$", "Executing command: ".. job.command .. " " .. table.concat(job.args, " "))
    vim.cmd('normal! G')
  end)
end

---@param job Job
---@param code integer
local function on_exit(job, code, signal)
  M.isRunning = false
  vim.schedule(function()
    if signal == 0 then
    vim.fn.appendbufline(M.buf, "$", "Process Finnished with Exit Code: " .. code)
    else
    vim.fn.appendbufline(M.buf, "$", "Process Finnished with Exit Code: " .. code .." ("..signal..")")
    end
    vim.cmd('normal! G')
  end)
  M.job = nil
  if #M.commandQueue > 0 then
    print("quue")
    local next_cmd = table.remove(M.commandQueue, 1)
    M.command(next_cmd.cmd, next_cmd.args, next_cmd.dir)
  end
end

---@param cmd string
---@param args table
---@param dir string
M.command = function(cmd, args, dir)
  args = args or {}
  dir = dir or vim.fn.getcwd()
  if (M.buf == nil or M.win == nil) then M.open_terminal() end
  if M.isRunning then
    table.insert(M.commandQueue, { cmd = cmd, args = args, dir = dir })
    return
  end
  local PlenaryJob = require("plenary.job")
  ---@diagnostic disable-next-line: missing-fields
  M.job = PlenaryJob:new({
    command = cmd,
    args = args,
    cwd = dir,
    interactive = false,
    detached = false,
    on_start = on_start,
    on_stderr = on_stderr,
    on_stdout = on_stdout,
    on_exit = on_exit,
  })
  M.job.cwd = dir
  M.job:start()
end
return M
