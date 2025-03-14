local M = { init = false }
M.setup = function(opts)
  opts = opts or {}
  if M.init then
    return
  end
  M.init = true
  M.json = require("scripts.compile-tools.json")
  M.json.setup(opts)
  M.terminal = require("scripts.compile-tools.terminal")
  M.terminal.setup(opts)
  M.syntax = require("scripts.compile-tools.syntax")
  M.syntax.setup(opts)
  M.module = nil

  vim.api.nvim_create_user_command("CompileTools", function(opts)
    local command = opts.fargs[1]
    if command == "clean" then
    elseif command == "reload" then
    elseif command == "generate" then
    elseif command == "build" then
    elseif command == "run" then
    elseif command == "toggle_term" then
      M.terminal.toggle_terminal()
    elseif command == "clear_term" then
      M.terminal.clear_terminal()
    elseif command == "command" then
      vim.ui.input({ prompt = "Enter command: " }, function(input)
        if input and input ~= "" then
          local cmd, args = input:match("^(%S+)%s*(.*)")
          M.terminal.send_command(cmd, vim.fn.split(args, "%s+"))
        else
          print("No command entered")
        end
      end)
    end
  end, {
    nargs = 1,
    complete = function()
      return { "clean", "reload", "generate", "build", "run", "command", "toggle_term", "clear_term" }
    end,
  })
end
M.load = function()
  if M.module then
    return
  end
  local project = M.json.decode_project()
  if not project then
    local dir = vim.fn.stdpath("config") .. "/lua/scripts/compile-tools/compilers"
    local files = vim.fn.globpath(dir, "*", false, true)
    local modules = {}
    for _, file in ipairs(files) do
      local filename = vim.fn.fnamemodify(file, ":t"):match("^(.-)%.") or vim.fn.fnamemodify(file, ":t")
      table.insert(modules, filename)
    end
    local json = {}
    vim.ui.select(modules, { prompt = "Select Compiler Module: " }, function(module)
      json.module = module
      require("scripts.compile-tools").json.encode_project(json)
      M.module = require("scripts.compile-tools.compilers." .. module)
      M.module.setup()
    end)
  else
    M.module = require("scripts.compile-tools.compilers." .. project.module)
  end
end
M.clean = function()
  if not M.json.decode_project() then return end
  if not M.module then M.load() end
  M.module = nil
  M.module.clean()
end
M.reload = function()
  if not M.json.decode_project() then return end
  if not M.module then M.load() end
  M.module.reload()
end
M.generate = function()
  if not M.json.decode_project() then return end
  if not M.module then M.load() end
  M.module.generate()
end

M.build = function()
  if not M.json.decode_project() then return end
  if not M.module then M.load() end
  M.module.build()
end
M.run = function()
  if not M.json.decode_project() then return end
  if not M.module then M.load() end
  M.module.run()
end
return M
