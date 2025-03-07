return {
  "mfussenegger/nvim-dap",
    keys = {
    { "<F1>", function() require("dap").continue() end, desc = "Run/Continue" },
    { "<F2>", function() require("dap").step_into() end, desc = "Step Into" },
    { "<F3>", function() require("dap").step_over() end, desc = "Step Over" },
    { "<F4>", function() require("dap").step_out() end, desc = "Step Out" },
    { "<F5>", function() require("dap").step_back() end, desc = "Step Back" },
    { "<F6>", function() require("dap").restart() end, desc = "Restart" },
    { "<F7>", function() require("dap").pause() end, desc = "Pause" },
    { "<F8>", function() require("dap").terminate() end, desc = "Terminate" },
    { "<F9>", function() require("dap").up() end, desc = "Move Up The Stack" },
    { "<F10>", function() require("dap").down() end, desc = "Move Down The Stack" },

    -- { "<leader>dc", false},
    { "<leader>do", false},
    { "<leader>di", false},
    { "<leader>dO", false},
    { "<leader>dP", false},
    { "<leader>dj", false},
    { "<leader>dk", false},
    { "<leader>dt", false},

    -- { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    -- { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },

    -- { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
    -- { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
    --
    -- { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
    -- { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
    --
    -- { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
    -- { "<leader>ds", function() require("dap").session() end, desc = "Session" },
    -- { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
  },
}
