return {
  "akinsho/toggleterm.nvim",
  lazy = true,
  config = function()
    require("toggleterm").setup({
      open_mapping = [[<c-\>]],
      shell = "pwsh",
    })
    vim.keymap.set("n", "<c-_>", "<CMD>ToggleTerm<CR>", { noremap = true, silent = true })
  end,
  keys = {
    {"<c-_>", "<CMD>ToggleTerm<CR>"},
    { [[<leader>/]] },
    {
      "<leader>tv",
      function()
        local count = vim.v.count1
        require("toggleterm").toggle(count, 60, vim.loop.cwd(), "vertical")
      end,
      desc = "ToggleTerm (vertical)",
    },
    {
      "<leader>th",
      function()
        local count = vim.v.count1
        require("toggleterm").toggle(count, 20, vim.loop.cwd(), "horizontal")
      end,
      desc = "ToggleTerm (horizontal)",
    },
    {
      "<leader>tf",
      function()
        local count = vim.v.count1
        require("toggleterm").toggle(count, 20, vim.loop.cwd(), "float")
      end,
      desc = "ToggleTerm (float)",
    },
    {
      "<leader>tb",
      function()
        local count = vim.v.count1
        require("toggleterm").toggle(count, 20, vim.loop.cwd(), "tab")
      end,
      desc = "ToggleTerm (fullscreen)",
    },
  },
}
