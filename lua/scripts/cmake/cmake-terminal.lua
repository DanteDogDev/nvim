local Terminal = {}
Terminal.Call =  function(cmd, syntax)
  if Terminal.job then
    print("Process is Already Running")
    return;
  end
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = vim.o.columns - 8,
    height = vim.o.lines - 8,
    col = 4,
    row = 2,
    border = 'single'
  })
  require("scripts.cmake.cmake-syntax").ApplySyntax(win)
  local function on_stdout(_, data)
    if data then
      local cleaned_data = vim.fn.trim(table.concat(data, '\n'))
      cleaned_data = cleaned_data:gsub("\r", "")
      local lines = vim.split(cleaned_data, '\n')
      local line_count = vim.api.nvim_buf_line_count(buf)
      vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, lines)
      vim.api.nvim_win_set_cursor(win, {line_count + #lines, 0})
    end
  end
  local function on_exit(_, exit_code)
    Terminal.job = nil
    vim.api.nvim_del_user_command("CMakeStop")
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    local line_count = vim.api.nvim_buf_line_count(buf) - 1
    vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, {"Process Finnished with Exit Code: " .. exit_code})
    if exit_code ~= 0 then
    vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, {"[ERROR]: Process Finnished with Exit Code: " .. exit_code})
    end
    vim.api.nvim_win_set_cursor(win, {line_count+2, 0})
  end

  local function stop_job()
    if Terminal.job then
      vim.fn.jobstop(Terminal.job)
      Terminal.job = nil
      local line_count = vim.api.nvim_buf_line_count(buf)
      vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, {"Process Stopped by User."})
      vim.api.nvim_win_set_cursor(win, {line_count + 1, 0})
      vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end
  end

  vim.api.nvim_create_user_command("CMakeStop", function()
    stop_job()
    vim.api.nvim_del_user_command("CMakeStop")
  end,{})
  vim.api.nvim_buf_set_keymap(buf, "n", "<c-c>", "<cmd>CMakeStop<CR>", { noremap = true, silent = true })

  Terminal.job = vim.fn.jobstart(cmd, {
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = on_stdout,
    on_exit = on_exit,
  })
end
return Terminal
