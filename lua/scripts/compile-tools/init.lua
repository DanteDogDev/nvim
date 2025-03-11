local M = { init = false}
M.setup = function(opts)
  opts = opts or {}
  if M.init then return end
  M.init = true
  M.terminal = require("scripts.compile-tools.terminal")
  M.terminal.setup(opts)
  M.json = require("scripts.compile-tools.json")
  M.json.setup(opts)
  M.syntax = require("scripts.compile-tools.syntax")
  M.syntax.setup(opts)
end
return M
