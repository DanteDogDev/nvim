local terminal = require("scripts.compile-tools").terminal
local json = require("scripts.compile-tools").json
local M = {}
local function select_build_type()
  local project = json.decode_project()
  if not project then return end
  vim.ui.select({ "debug", "release" }, { prompt = "Select Build Type: " }, function(build_type)
    if not build_type then print("WTF CHOOSE A GOD DAM BUILD TYPE") end
    project.build_type = build_type
    json.encode_project(project)
  end)
end
local function select_kit()
  local cmake = json.decode_module("cmake")
  if type(cmake) ~= "table" then
    return
  end
  local project = json.decode_project()
  if not project then return end
  local names = {}
  for _, item in ipairs(cmake) do
    table.insert(names, item.name)
  end
  vim.ui.select(names, { prompt = "Select CMake kit: " }, function(kit)
    for _, item in ipairs(cmake) do
      if item.name == kit then
        project.settings = item
        json.encode_project(project)
        select_build_type()
        return
      end
    end
  end)
end
local function move_compile_commands()
  local project = json.decode_project()
  if not project then return end
  local target = "./bin/" .. project.build_type .. "/compile_commands.json"
  local dest = vim.fn.getcwd() .. "/compile_commands.json"
  vim.fn.rename(target, dest)
end

M.setup = function()
  select_kit()
end
M.reload = function()
  select_build_type()
end
M.clean = function()
  print("CLEANED")
end
M.generate = function()
  local project = json.decode_project()
  if not project then return end
  local dir = "./bin/" .. project.build_type
  if project.settings.envSetupScript then
    terminal.send_command({
      cmd = "powershell",
      args = {"-Command", "& '" .. project.settings.envSetupScript .. "'"},
      dir = dir
    })
  end
  local args = {} ---@type string[]
  if project.settings.generator then
    table.insert(args, '-G"' .. project.settings.generator .. '"')
  end
  if project.build_type == "debug" then
    table.insert(args, "-DCMAKE_BUILD_TYPE=Debug")
  elseif project.build_type == "release" then
    table.insert(args, "-DCMAKE_BUILD_TYPE=Release")
  end
  if project.settings.compilers then
    if project.settings.compilers.C then
      table.insert(args, '-DCMAKE_C_COMPILER="' .. project.settings.compilers.C .. '"')
    end
    if project.settings.compilers.CXX then
      table.insert(args, '-DCMAKE_CXX_COMPILER="' .. project.settings.compilers.CXX .. '"')
    end
  end
  if project.settings.toolchainFile then
    table.insert(args, '-DCMAKE_TOOLCHAIN_FILE="' .. project.settings.toolchainFile .. '"')
  end

  table.insert(args, '-B "' .. dir .. '"')
  terminal.send_command({
    cmd = "cmake",
    args = args
  })
  terminal.send_command(move_compile_commands)
end
M.build = function()
  local project = json.decode_project()
  if not project then return end
  local dir = "./bin/" .. project.build_type
  terminal.send_command({
    cmd = "cmake",
    args = {"--build", dir}
  })
end
M.run = function(retarget)
  retarget = retarget or false
  local project = json.decode_project()
  if not project then return end
  if not project.target or retarget then
    local dir = "./bin/" .. project.build_type
    local result = vim.fn.system("fd . " .. dir .. " -e exe --exclude CMakeFiles")
    local targets = vim.fn.split(result, "\n")
    vim.ui.select(targets, {}, function(target)
      if not target then return end
      project.target = target
      json.encode_project(project)
      terminal.send_command({
        cmd = "powershell",
        args = {"& '"..project.target.."'"}
      })
    end)
  else
    terminal.send_command({
      cmd = "powershell",
      args = {"& '"..project.target.."'"}
    })
  end
end
M.syntax = function() -- FIXME: THIS IS SHIT
   return {
    { group = "@constructor", pattern =  "[0-9]" },
    { group = "@comment.error", pattern =  "\\verror:.*", },
    { group = "@comment.error", pattern =  "error\\w", },
    { group = "@comment.warning", pattern =  "\\vwarning:.*", },
    { group = "@comment.warning", pattern =  "warning\\w", },
    { group = "@comment.note", pattern =  "\\vnote:.*", },
    { group = "@keyword", pattern =  "\\[.*\\]" },
    { group = "@constructor", pattern =  "\\[-.*\\]" },
    { group = "@annotation", pattern =  "\\[\\[.*\\]\\]" },
    { group = "String", pattern =  '"[^"]*"' },
    { group = "String", pattern =  "'[^']*'" },
    { group = "Directory", pattern =  "\\zs[A-Z]:\\(.*\\)(\\d\\+,\\d\\+):" },
    { group = "@comment", pattern =  "\\zs|.*$" },
    { group = "none", pattern =  "\\zs\\^\\(.*\\)" },
    { group = "conceal", pattern =  "\\zsIn file included from \\(.*\\)" },
  }
end
return M
