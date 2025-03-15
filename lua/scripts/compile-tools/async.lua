---@diagnostic disable: missing-fields, param-type-mismatch
local M = {
  command_queue = {},
  is_running = false,
  buf = nil,
  env = {},
  job = nil,
}
M.setup = function()
  local env = require("scripts.compile-tools").json.decode_module("environment")
  if not env then
    return
  end
  for key, value in pairs(env) do
    M.env[key] = value
  end
end

local function process(data)
  if not data then return {} end
  local result = {}
  for match in data:gmatch("([^\n]*\n?)") do
    table.insert(result, match)
  end
  print(vim.inspect(result))
  return result
end

local function on_stdout(err, data)
  assert(not err, err)
  vim.schedule(function()
    data = process(data)
    for _, line in ipairs(data) do
      line = string.gsub(line,"\n","") -- FIXME: TEMP GET RID OF LATER WHEN I GET THE FUCKING BUG
      line = string.gsub(line,"\r","")
      if line then vim.fn.appendbufline(M.buf, "$", line)end
    end
  end)
end

local function on_stderr(err, data)
  assert(not err, err)
  vim.schedule(function()
    data = process(data)
    for _, line in ipairs(data) do
      line = string.gsub(line,"\n","") -- FIXME: TEMP GET RID OF LATER WHEN I GET THE FUCKING BUG
      line = string.gsub(line,"\r","")
      if line then vim.fn.appendbufline(M.buf, "$", line)end
    end
  end)
end

local function on_exit(code, signal)
  vim.schedule(function()
    M.is_running = false
    M.job = nil
    M.opts = nil
    M.stdin = nil
    M.stdout = nil
    M.stderr = nil
    vim.fn.appendbufline(M.buf, "$", "Process Finnished with Exit Code: " .. code .. " (" .. signal .. ")")
    M.job = nil
    if #M.command_queue > 0 then
      local next_cmd = table.remove(M.command_queue, 1)
      M.command(next_cmd.cmd, next_cmd.args, next_cmd.dir)
    end
  end)
end

local function on_start()
  M.is_running = true
  vim.uv.read_start(M.stdout, on_stdout)
  vim.uv.read_start(M.stderr, on_stderr)
end

M.force_stop = function()
  vim.uv.kill(M.job, "SIGTERM")
end

---@param cmd string
---@param args string[]?
---@param dir string?
M.command = function(cmd, args, dir)
  args = args or {}
  dir = dir or vim.fn.getcwd()
  if dir:sub(1, 2) == "./" then
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
  for i, arg in ipairs(args) do
    for key, value in pairs(M.env) do
      if string.find(arg, key) then
        args[i] = string.gsub(arg, key, value)
      end
    end
  end
  M.stdin = vim.uv.new_pipe()
  M.stdout = vim.uv.new_pipe()
  M.stderr = vim.uv.new_pipe()
  vim.fn.appendbufline(M.buf, "$", dir .. ">" .. cmd .. " " .. table.concat(args," "))
  M.job = vim.uv.spawn(cmd, {
    cwd = dir,
    args = args,
    stdio = { M.stdin, M.stdout, M.stderr },
    hide = true,
    detached = false,
    verbatim = true,
  }, on_exit)
  on_start()
end
return M
