local M = {init = false}
M.setup = function()
  if M.init then return end
  M.init = true
  local CMake = require("scripts.cmake.cmake")

  vim.api.nvim_create_user_command("CMakeClean", function()
    CMake.Clean()
  end, {})

  vim.api.nvim_create_user_command("CMakeGenerate", function()
    CMake.Generate()
  end, {})

  vim.api.nvim_create_user_command("CMakeBuild", function()
    vim.cmd("wa")
    CMake.Build()
  end, {})

  vim.api.nvim_create_user_command("CMakeReload", function()
    CMake.Reload()
  end, {})

  vim.api.nvim_create_user_command("CMakeRun", function(opts)
    print(vim.fn.getcwd() .. "/" .. opts.args)
    CMake.Run(opts.args)
  end, { nargs = "?",
      complete = function()
        return CMake.RunCompletion()
      end
    }
  )

  -- CMake binds
  require("which-key").add({
    { "<leader>m", group = "CMake", icon = "" },
    { "<leader>mg","<CMD>CMakeGenerate<CR>", group = "Generate", icon = "" },
    { "<leader>mb","<CMD>CMakeBuild<CR>", group = "Build", icon = "󱌣" },
    { "<leader>mR","<CMD>CMakeReload<CR>", group = "Reload", icon = "" },
    { "<leader>mc","<CMD>CMakeClean<CR>", group = "Clean", icon = "󰗣" },
    { "<leader>mr","<CMD>CMakeRun<CR>", group = "Run", icon = "" },
  })
end
return M
