local CMake = {}
local Terminal = require("scripts.cmake.cmake-terminal")
local Json = require("scripts.cmake.cmake-json")

CMake.Clean = function()
  if vim.fn.filereadable(vim.fn.getcwd() .. "/CMakeLists.txt") == 0 then
    print("[ERROR] CMakeLists.txt not found!!")
    return
  end
  print("Cleaning Files")
  vim.api.nvim_command('!cmd /c "' .. vim.fn.stdpath("config") .. '/cmake/clean.bat"')
end

CMake.Generate = function()
  if vim.fn.filereadable(vim.fn.getcwd() .. "/CMakeLists.txt") == 0 then
    print("[ERROR] CMakeLists.txt not found!!")
    return
  end
  local json = Json.Decode()
  if json then
    vim.ui.select({ "debug", "release"}, { prompt = "What build type do you want: " }, function(build_type)
      if build_type == nil then return end
      print("Generating build files {Generator:"..json.generator..", Build Type:"..build_type.."}")
      Terminal.Call(vim.fn.stdpath("config") .. "/cmake/kits/" .. json.generator .. "/" .. build_type .. "/generate.bat")
      json.build_type = build_type
      Json.Encode(json.generator)
    end)
  else
    vim.ui.select({ "ninja", "msvs", "ninja-msvs" }, { prompt = "How do you want to compile?" }, function(generator)
      if generator == nil then return end
      vim.ui.select({ "debug", "release" }, { prompt = "What build type do you want: " }, function(build_type)
        if build_type == nil then return end
        print("Generating build files {Generator:"..generator..", Build Type:"..build_type.."}")
        json = {}
        json.generator = generator
        json.build_type = build_type
        Json.Encode(json)
        Terminal.Call(vim.fn.stdpath("config") .. "/cmake/kits/" .. generator .. "/" .. build_type .. "/generate.bat")
      end)
    end)
  end
end

CMake.Build = function()
  if vim.fn.filereadable(vim.fn.getcwd() .. "/CMakeLists.txt") == 0 then
    print("[ERROR] CMakeLists.txt not found!!")
    return
  end
  if (vim.fn.filereadable(vim.fn.getcwd() .. "/bin/cmake.json")) == 0 then
    print("[ERROR] cmake.json not found!! Please Generate CMake binary")
    return
  end
  local json = Json.Decode()
  if not json then print("ERROR TO DECODE JSON") return end
  print("Building Files {Generator:"..json.generator..", Build Type:"..json.build_type.."}")
  Terminal.Call(vim.fn.stdpath("config") .. "/cmake/kits/" .. json.generator .. "/" .. json.build_type .. "/build.bat")
end

CMake.Reload = function()
  if vim.fn.filereadable(vim.fn.getcwd() .. "/CMakeLists.txt") == 0 then
    print("[ERROR] CMakeLists.txt not found!!")
    return
  end
  if (vim.fn.filereadable(vim.fn.getcwd() .. "/bin/cmake.json")) == 0 then
    print("[ERROR] cmake.json not found!! Please Generate CMake binary")
    return
  end
  local json = Json.Decode()
  if not json then print("ERROR TO DECODE JSON") return end
  print("Reloading Files {Generator:"..json.generator..", Build Type:"..json.build_type.."}")
  Terminal.Call(vim.fn.stdpath("config") .. "/cmake/kits/" .. json.generator .. "/" .. json.build_type .. "/generate.bat")
end

CMake.RunCompletion = function ()
  if vim.fn.filereadable(vim.fn.getcwd() .. "/CMakeLists.txt") == 0 then
    print("[ERROR] CMakeLists.txt not found!!")
    return
  end
  if (vim.fn.filereadable(vim.fn.getcwd() .. "/bin/cmake.json")) == 0 then
    print("[ERROR] cmake.json not found!! Please Generate CMake binary")
    return
  end
  local json = Json.Decode()
  if not json then return end
  local dir = vim.fn.getcwd() .. "/bin/" .. json.build_type
  local files = vim.fn.globpath(dir, "**/*", true, true)
  local file_list = {}
  for _, file in ipairs(files) do
    if vim.fn.isdirectory(file) == 0 then
      local filename = vim.fn.fnamemodify(file, ":t")
      if (filename:find(".exe")) then
        table.insert(file_list, filename)
      end
    end
  end
  return file_list
end

CMake.Run = function(cmd)
  if vim.fn.filereadable(vim.fn.getcwd() .. "/CMakeLists.txt") == 0 then
    print("[ERROR] CMakeLists.txt not found!!")
    return
  end
  if (vim.fn.filereadable(vim.fn.getcwd() .. "/bin/cmake.json")) == 0 then
    print("[ERROR] cmake.json not found!! Please Generate CMake binary")
    return
  end
  local json = Json.Decode()
  if not json then return end
  if cmd ~= "" then
    json.current_target = cmd
  end
  if json.current_target then
    local dir = vim.fn.getcwd() .. "/bin/" .. json.build_type
    local files = vim.fn.globpath(dir, "**/*", true, true)
    local file_dir
    for _, file in ipairs(files) do
      if vim.fn.isdirectory(file) == 0 then
        local filename = vim.fn.fnamemodify(file, ":t")
        local current_file_dir = vim.fn.fnamemodify(file, ":p")
        if filename == json.current_target then
          file_dir = current_file_dir
          break
        end
      end
    end
    Json.Encode(json)
    Terminal.Call(file_dir)
  else
    vim.ui.select(CMake.RunCompletion(), { prompt = "Which Target do you select" }, function(picked)
      if picked then
        CMake.Run(picked)
      end
    end)
  end
end
return CMake
