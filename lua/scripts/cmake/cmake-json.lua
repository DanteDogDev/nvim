local Json = {}
Json.Decode =  function()
  local file_path = vim.fn.getcwd() .. "/bin/cmake.json"
  local file = io.open(file_path, "r")
  if file then
    local json = vim.fn.json_decode(file:read("*all"))
    file:close()
    return json
  else
    return nil
  end
end

Json.Encode = function(settings)
  vim.fn.mkdir(vim.fn.getcwd() .. "/bin","p")
  local file_path = vim.fn.getcwd() .. "/bin/cmake.json"
  local json_string = vim.fn.json_encode(settings)
  local file = io.open(file_path, "w")
  if file then
    file:write(json_string)
    file:close()
  else
  end
end
return Json
