local M = {
  json = {
    module = "cmake"
  },
}
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
M.setup = function()
  select_kit()
end
M.clean = function()
  vim.fn.delete("bin", "rf")
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
    terminal.send_command(json.settings.envSetupScript, {}, dir)
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
end
M.build = function()
  local json = require("scripts.compile-tools").json.decode_project()
  if not json then return end
  local dir = "./bin/" .. json.build_type
  local terminal = require("scripts.compile-tools").terminal
  terminal.send_command("cmake", {"--build"}, dir)
end
M.run = function() end
return M
