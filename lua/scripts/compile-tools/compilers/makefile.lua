local M = {}
M.setup = function() end
M.reload = function() end
M.clean = function() end
M.generate = function() end
M.build = function() end
M.run = function(retarget)
  retarget = retarget or false
end
M.syntax = function()
  return {
    { group = "@constructor", pattern = "[0-9]" },
  }
end
return M
