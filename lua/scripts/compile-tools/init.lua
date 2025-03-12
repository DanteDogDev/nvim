local M = { init = false}
M.setup = function(opts)
  opts = opts or {}
  if M.init then return end
  opts.self = M
  M.init = true
  M.json = require("scripts.compile-tools.json")
  M.json.setup(opts)
  M.terminal = require("scripts.compile-tools.terminal")
  M.terminal.setup(opts)
  M.syntax = require("scripts.compile-tools.syntax")
  M.syntax.setup(opts)
end
M.clean = function()
end
M.reload = function()
end
M.generate = function()
end
M.build = function()
end
M.run = function()
end
M.build_and_run = function()
end
return M
