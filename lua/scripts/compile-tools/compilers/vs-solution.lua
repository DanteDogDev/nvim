local M = {}
M.setup = function()
  local json = require("scripts.compile-tools").json.decode_project()
  local path = vim.fn.input("Path to solution", vim.fn.getcwd() .. "/", "file")
  json.vs = path
  require("scripts.compile-tools").json.encode_project(json)
end
M.reload = function()
end
M.clean = function()
  print("UNIMPLEMENTED FUNCTION")
  vim.fn.delete("obj", "rf")
end
M.generate = function()
  print("UNIMPLEMENTED FUNCTION")
end
M.build = function()
  local json = require("scripts.compile-tools").json.decode_project()
  if not json then return end
  -- local dir = "./bin/" .. json.build_type
  local terminal = require("scripts.compile-tools").terminal
  terminal.send_command("powershell", {"'"..json.vs.."'"})
  terminal.send_command("powershell", {"-Command", "& '" .. "MSBUILD".. "'", "'" ..json.vs .. "'"})
  terminal.send_command("powershell", {"./clang-build.ps1 -export-json"})
end
M.run = function(retarget)
  retarget = retarget or false
  local json = require("scripts.compile-tools").json.decode_project()
  if not json then return end
  if not json.target or retarget then
    local dir = "./bin/"
    local result = vim.fn.system("fd . " .. dir .. " -e exe --exclude CMakeFiles")
    local targets = vim.fn.split(result, "\n")
    vim.ui.select(targets, {}, function(target)
      if not target then return end
      json.target = target
      require("scripts.compile-tools").json.encode_project(json)
      require("scripts.compile-tools").terminal.send_command("powershell",{"& '"..json.target.."'"})
    end)
  else
    require("scripts.compile-tools").terminal.send_command("powershell", {"& '"..json.target.."'"})
  end
end
M.syntax = function()
  return {
    { group = "@constructor", pattern = "[0-9]" },
  }
end
return M
