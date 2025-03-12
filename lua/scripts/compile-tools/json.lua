local M = {}
M.setup = function(opts)
  opts = opts or {}
end

---@param module string
M.decode_module = function(module)
  local file_path = vim.fn.stdpath("config") .. "/compile-tools/" .. module .. ".json"
  local file = io.open(file_path, "r")
  if file then
    local json = vim.fn.json_decode(file:read("*all"))
    file:close()
    return json
  end
  return nil
end

M.decode_project = function()
  local file_path = vim.fn.getcwd() .. "/bin/compile-tools.json"
  local file = io.open(file_path, "r")
  if file then
    local json = vim.fn.json_decode(file:read("*all"))
    file:close()
    return json
  end
  return nil
end

M.encode_project = function(settings)
  vim.fn.mkdir(vim.fn.getcwd() .. "/bin", "p")
  local file_path = vim.fn.getcwd() .. "/bin/compile-tools.json"
  local json_string = vim.fn.json_encode(settings)
  local file = io.open(file_path, "w")
  if file then
    file:write(json_string)
    file:close()
  end
end
return M
