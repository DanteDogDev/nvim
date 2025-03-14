---@diagnostic disable: param-type-mismatch, unused-local
local M = {
  buf = nil,
  is_running = false,
  terminal = nil,
  job = nil,
  command_queue = {},
  env = {}
}
M.setup = function()
  if M.init then return end
  M.init = true
  local env = require("scripts.compile-tools").json.decode_module("environment")
  for key, value in pairs(env) do
    M.env[key] = value
  end
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
  M.is_running = true
  vim.schedule(function()
    vim.fn.appendbufline(M.buf, "$", M.job.cwd)
    vim.fn.appendbufline(M.buf, "$", "Executing command: ".. job.command .. " " .. table.concat(job.args, " "))
    vim.cmd('normal! G')
  end)
end

---@param job Job
---@param code integer
local function on_exit(job, code, signal)
  vim.schedule(function()
    M.is_running = false
    if signal == 0 then
    vim.fn.appendbufline(M.buf, "$", "Process Finnished with Exit Code: " .. code)
    else
    vim.fn.appendbufline(M.buf, "$", "Process Finnished with Exit Code: " .. code .." ("..signal..")")
    end
    vim.cmd('normal! G')
    M.job = nil
    if #M.command_queue > 0 then
      local next_cmd = table.remove(M.command_queue, 1)
      M.command(next_cmd.cmd, next_cmd.args, next_cmd.dir)
    end
  end)
end

M.force_stop = function()
  if not M.is_running or M.job == nil then return end
  M.job:shutdown(-1, 'SIGTERM')
  M.job = nil
end

---@param cmd string
---@param args string[]
---@param dir string
M.command = function(cmd, args, dir)
  args = args or {}
  dir = dir or vim.fn.getcwd()
  if dir:sub(1, 2) == './' then
    dir = vim.fn.getcwd() .. dir:sub(2)
  end
  vim.fn.mkdir(dir, "p")
  if M.is_running then
    table.insert(M.command_queue, { cmd = cmd, args = args, dir = dir })
    return
  end
  if M.env[cmd] then
    cmd = M.env[cmd]
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
