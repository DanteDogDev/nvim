local terminal = require("scripts.compile-tools").terminal
local json = require("scripts.compile-tools").json

local M = {}
M.setup = function()
  local project = json.decode_project()
  if not project then return end
  local path = vim.fn.input("Path to solution", vim.fn.getcwd() .. "/", "file")
  project.vs = path
  json.encode_project(project)
end

M.reload = function()
  local project = json.decode_project()
  if not project then return end
  local result = vim.fn.system("fd . " .. " -e sln --exclude CMakeFiles")
  local targets = vim.fn.split(result, "\n")
  vim.ui.select(targets, {}, function(target)
    if not target then return end
    project.vs = target
    json.encode_project(project)
  end)
end

M.clean = function()
  print("WORK IN PROGRESS")
  vim.fn.delete("obj", "rf")
end
M.generate = function()
  terminal.send_command({
    cmd = "powershell",
    args = {"./clang-build.ps1 -export-json"},
  })
  print("WORK IN PROGRESS")
end

M.build = function()
  local project = json.decode_project()
  if not project then return end
  terminal.send_command({
    cmd = "powershell",
    args = {"-Command", "& '" .. "MSBUILD".. "'", "'" ..project.vs .. "'"},
  })
end

M.run = function(retarget)
  retarget = retarget or false
  local project = json.decode_project()
  if not project then return end
  if not project.target or retarget then
    local dir = "./bin/"
    local result = vim.fn.system("fd . " .. dir .. " -e exe --exclude CMakeFiles")
    local targets = vim.fn.split(result, "\n")
    vim.ui.select(targets, {}, function(target)
      if not target then return end
      project.target = target
      json.encode_project(project)
      terminal.send_command({
        cmd = "powershell",
        args = {"& '"..project.target.."'"},
      })
    end)
  else
    terminal.send_command({
      cmd = "powershell",
      args = {"& '"..project.target.."'"},
    })
  end
end

M.syntax = function()
  return {
    { group = "@constructor", pattern = "[0-9]" },
  }
end

return M
