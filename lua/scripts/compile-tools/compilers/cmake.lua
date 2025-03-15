local M = {
  json = {
    module = "cmake"
  },
}
M.syntax = function() -- FIXME: THIS IS SHIT
   return {
    { group = "@constructor", pattern =  "[0-9]"},
    { group = "@comment.error", pattern =  "\\verror:.*",},
    { group = "@comment.error", pattern =  "error\\w",},
    { group = "@comment.warning", pattern =  "\\vwarning:.*",},
    { group = "@comment.warning", pattern =  "warning\\w",},
    { group = "@comment.note", pattern =  "\\vnote:.*",},
    { group = "@keyword", pattern =  "\\[.*\\]"},
    { group = "@constructor", pattern =  "\\[-.*\\]"},
    { group = "@annotation", pattern =  "\\[\\[.*\\]\\]"},
    { group = "String", pattern =  '"[^"]*"'},
    { group = "String", pattern =  "'[^']*'"},
    { group = "Directory", pattern =  "\\zs[A-Z]:\\(.*\\)(\\d\\+,\\d\\+):"},
    { group = "@comment", pattern =  "\\zs|.*$"},
    { group = "none", pattern =  "\\zs\\^\\(.*\\)"},
    { group = "conceal", pattern =  "\\zsIn file included from \\(.*\\)"},
  }
end
local function select_build_type()
  vim.ui.select({ "debug", "release" }, { prompt = "Select Build Type: " }, function(build_type)
    M.json.build_type = build_type
    require("scripts.compile-tools").json.encode_project(M.json)
  end)
end
local function select_kit()
  local cmake = require("scripts.compile-tools").json.decode_module("cmake")
  if type(cmake) ~= "table" then
    return
  end
  local names = {}
  for _, item in ipairs(cmake) do
    table.insert(names, item.name)
  end
  vim.ui.select(names, { prompt = "Select CMake kit: " }, function(kit)
    for _, item in ipairs(cmake) do
      if item.name == kit then
        M.json.settings = item
        select_build_type()
        return
      end
    end
  end)
end
local function move_compile_commands()
  -- local json = require("scripts.compile-tools").json.decode_project()
  -- if not json then return end
  -- local dir = "./bin/" .. json.build_type
  -- require("scripts.compile-tools").terminal.send_command("mv", {"-Force ./compile_commands.json ../../"},dir)
end
M.setup = function()
  select_kit()
end
M.clean = function()
end
M.reload = function()
  select_build_type()
end
M.generate = function()
  local json = require("scripts.compile-tools").json.decode_project()
  if not json then return end
  local dir = "./bin/" .. json.build_type
  local terminal = require("scripts.compile-tools").terminal
  if json.settings.envSetupScript then
    terminal.send_command("powershell", {"-Command", "& '" .. json.settings.envSetupScript .. "'"}, dir)
  end
  local args = {} ---@type string[]
  if json.settings.generator then
    table.insert(args, '-G"' .. json.settings.generator .. '"')
  end
  if json.build_type == "debug" then
    table.insert(args, "-DCMAKE_BUILD_TYPE=Debug")
  elseif json.build_type == "release" then
    table.insert(args, "-DCMAKE_BUILD_TYPE=Release")
  end
  if json.settings.compilers then
    if json.settings.compilers.C then
      table.insert(args, '-DCMAKE_C_COMPILER="' .. json.settings.compilers.C .. '"')
    end
    if json.settings.compilers.CXX then
      table.insert(args, '-DCMAKE_CXX_COMPILER="' .. json.settings.compilers.CXX .. '"')
    end
  end
  if json.settings.toolchainFile then
    table.insert(args, '-DCMAKE_TOOLCHAIN_FILE="' .. json.settings.toolchainFile .. '"')
  end

  table.insert(args, '-B "' .. dir .. '"')
  terminal.send_command("cmake", args)
  move_compile_commands()
end
M.build = function()
  local json = require("scripts.compile-tools").json.decode_project()
  if not json then return end
  local dir = "./bin/" .. json.build_type
  local terminal = require("scripts.compile-tools").terminal
  terminal.send_command("cmake", {"--build", dir})
end
M.run = function(retarget)
  retarget = retarget or false
  local json = require("scripts.compile-tools").json.decode_project()
  if not json then return end
  if not json.target or retarget then
    local dir = "./bin/" .. json.build_type
    local result = vim.fn.system("fd . " .. dir .. " -e exe --exclude CMakeFiles")
    local targets = vim.fn.split(result, "\n")
    vim.ui.select(targets, {}, function(target)
      json.target = target
      require("scripts.compile-tools").json.encode_project(json)
      require("scripts.compile-tools").terminal.send_command(json.target)
    end)
  else
    require("scripts.compile-tools").terminal.send_command(json.target)
  end
end
return M
