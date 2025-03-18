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
  M.module = nil

  require("which-key").add({
    { "<leader>m", group = "Compiler Tools", icon = ":3" },
    { "<leader>mm",":lua require('scripts.compile-tools').load()<CR>", group = "Load Module", icon = ":3" },
    { "<leader>mg",":lua require('scripts.compile-tools').generate()<CR>", group = "Generate", icon = ":3" },
    { "<leader>mb",":lua require('scripts.compile-tools').build()<CR>", group = "Build", icon = ":3" },
    { "<leader>ml",":lua require('scripts.compile-tools').reload()<CR>", group = "Reload", icon = ":3" },
    { "<leader>mc",":lua require('scripts.compile-tools').clean()<CR>", group = "Clean", icon = ":3" },
    { "<leader>mr",":lua require('scripts.compile-tools').run()<CR>", group = "Run", icon = ":3" },
    { "<leader>mR",":lua require('scripts.compile-tools').build_and_run()<CR>", group = "Build And Run", icon = ":3" },
    { "<leader>mt",":lua require('scripts.compile-tools').terminal.toggle_terminal()<CR>", group = "Toggle Terminal", icon = ":3" },
  })
end
M.load = function()
  if M.json.decode_project() and M.module then
    return
  end
  local project = M.json.decode_project()
  if not project then
    local dir = vim.fn.stdpath("config") .. "/lua/scripts/compile-tools/compilers"
    local files = vim.fn.globpath(dir, "*.lua", false, true)
    local modules = {}
    for _, file in ipairs(files) do
      local filename = vim.fn.fnamemodify(file, ":t"):match("^(.-)%.") or vim.fn.fnamemodify(file, ":t")
      table.insert(modules, filename)
    end
    local json = {}
    vim.ui.select(modules, { prompt = "Select Compiler Module: " }, function(module)
      if not module then return end
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
  if not M.json.decode_project() then print("PROJECT NOT FOUND") return end
  if not M.module then M.load() end
  M.module.clean()
  vim.fn.delete("bin", "rf")
  M.module = nil
end
M.reload = function()
  if not M.json.decode_project() then print("PROJECT NOT FOUND") return end
  if not M.module then M.load() end
  M.module.reload()
end
M.generate = function()
  if not M.json.decode_project() then print("PROJECT NOT FOUND") return end
  if not M.module then M.load() end
  M.module.generate()
end

M.build = function()
  if not M.json.decode_project() then print("PROJECT NOT FOUND") return end
  if not M.module then M.load() end
  M.module.build()
end
M.run = function()
  if not M.json.decode_project() then print("PROJECT NOT FOUND") return end
  if not M.module then M.load() end
  M.module.run()
end

M.build_and_run = function()
  if not M.json.decode_project() then print("PROJECT NOT FOUND") return end
  if not M.module then M.load() end
  M.module.build()
  M.terminal.send_command( {
    func = function() M.module.run(true) end
  })
end
M.apply_syntax = function()
  if not M.json.decode_project() then print("PROJECT NOT FOUND") return end
  if not M.module then M.load() end
  if not M.terminal.active then return end
  for _, id in ipairs(M.terminal.match_id) do
    vim.fn.matchdelete(id)
  end
  local matches = M.module.syntax()
  for _, match in ipairs(matches) do
    local id = vim.fn.matchadd(match.group, match.pattern, 100, -1, {window = M.terminal.win})
    table.insert(M.terminal.match_id, id)
  end
end
return M
