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
    if match ~= "" then
      table.insert(result, match)
    end
  end
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
    M.stdout:read_stop()
    M.stderr:read_stop()
    vim.fn.appendbufline(M.buf, "$", "Process Finnished with Exit Code: " .. code .. " signal(" .. signal .. ")")
    M.job = nil
    if #M.command_queue > 0 then
      local next_opts = table.remove(M.command_queue, 1)
      M.queue_cmd(next_opts)
    end
  end)
end

local function on_start()
  M.is_running = true
  vim.uv.read_start(M.stdout, on_stdout)
  vim.uv.read_start(M.stderr, on_stderr)
end

M.force_stop = function()
  if M.is_running then
    M.job:kill(15)
  end
end

local function process_opts(opts)
  opts.args = opts.args or {}
  opts.dir = opts.dir or vim.fn.getcwd()
  if opts.dir:sub(1, 2) == "./" then
    opts.dir = vim.fn.getcwd() .. opts.dir:sub(2)
  end
  vim.fn.mkdir(opts.dir, "p")
  if M.env[opts.cmd] then
    opts.cmd = M.env[opts.cmd]
  end
  for i, arg in ipairs(opts.args) do
    for key, value in pairs(M.env) do
      if string.find(arg, key) then
        opts.args[i] = string.gsub(arg, key, value)
      end
    end
  end
  return opts
end

M.queue_cmd = function(opts)
  if M.is_running then table.insert(M.command_queue, opts) return end
  if opts.func then opts.func() return end
  opts = process_opts(opts)

  M.stdin = vim.uv.new_pipe()
  M.stdout = vim.uv.new_pipe()
  M.stderr = vim.uv.new_pipe()
  vim.fn.appendbufline(M.buf, "$", opts.dir .. ">" .. opts.cmd .. " " .. table.concat(opts.args," "))
  M.job = vim.uv.spawn(opts.cmd, {
    cwd = opts.dir,
    args = opts.args,
    stdio = { M.stdin, M.stdout, M.stderr },
    hide = true,
    detached = false,
    verbatim = true,
  }, on_exit)
  on_start()
end
return M
