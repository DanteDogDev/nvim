local parser = {
  expressions = {},
  replacer = {}
}

parser.register = function(expr, replacer)
  parser.expressions[expr] = replacer
end

parser.parse = function(input)
  for expr, replacer in pairs(parser.expressions) do
    local replace = replacer()
    input = input:gsub(expr, replace)
  end
  return input
end

parser.insert = function(opts)
  local dir = vim.fn.stdpath("config") .. "/templates"
  local files = vim.fn.globpath(dir, "**/*", true, true)
  local file_dir
  for _, file in ipairs(files) do
    if vim.fn.isdirectory(file) == 0 then
      local filename = vim.fn.fnamemodify(file, ":t")
      local current_file_dir = vim.fn.fnamemodify(file, ":p")
      if filename == opts then
        file_dir = current_file_dir
        break
      end
    end
  end
  if not file_dir then
    print("Error: Template file '" .. opts .. "' not found.")
    return
  end
  local file = io.open(file_dir, "r")
  if not file then
    print("Error: Could not open file at " .. file_dir)
    return
  end
  local contents = file:read("*all")
  file:close()
  if not contents or contents == "" then
    print("Error: Template file '" .. opts .. "' is empty.")
    return
  end
  local parsed_contents = parser.parse(contents)
  if parsed_contents then
    local current_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(current_buf, 0, 0, false, vim.split(parsed_contents, "\n"))
    print("Parsed '" .. opts .. "' template into current buffer")
  else
    print("Error: Parsing failed for template '" .. opts .. "'")
  end
end

parser.setup = function()
  parser.register('${FILENAME}', function() return vim.fn.expand('%:t:r') end)
  parser.register('${DATE}', function() return os.date("%d/%m/%y") end)
  parser.register('${AUTHOR}', function() return vim.fn.system("git config user.name"):gsub("\n", "") end)
  parser.register('${EMAIL}', function() return vim.fn.system("git config user.email"):gsub("\n", "") end)
  parser.register('${PROJECT}', function() return vim.fn.system('powershell -Command "Split-Path -Leaf (Get-Location)"'):gsub("\n", "") end)

  local id = vim.api.nvim_create_augroup("Templates", {clear = false})
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = id,
    callback = function()
      local file_path = vim.fn.expand("%:p")
      local file_size = vim.fn.getfsize(file_path)
      local extension = file_path:match("%.([^.]+)$")
      if file_size == 0 then
        parser.insert(extension .. ".tpl")
      end
    end,
  })

  vim.api.nvim_create_user_command("Template", function(opts)
    parser.insert(opts.args)
  end, {
      nargs = 1,  -- Expect one argument
      ---@diagnostic disable-next-line: unused-local
      complete = function(arglead, cmdline, cursorpos) -- Gets all the files from the templates folder
        local currPath = vim.fn.expand("%:p")
        local extension = currPath:match("%.([^.]+)$")

        local dir = vim.fn.stdpath("config") .. "/templates"
        local files = vim.fn.globpath(dir, "**/*", true, true)
        local file_list = {}
        for _, file in ipairs(files) do
          if vim.fn.isdirectory(file) == 0 then  -- 0 means it's a file, not a directory
            local filename = vim.fn.fnamemodify(file, ":t")  -- ":t" strips the directory, leaving just the filename
            if (filename:find(".tpl")) then
              if (filename:find(extension)) then
                table.insert(file_list, filename)
              end
            else
              table.insert(file_list, filename)
            end
          end
        end
        return file_list
      end,
    })

end
return parser
