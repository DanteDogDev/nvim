return {
  { "Civitasv/cmake-tools.nvim", enabled = false }, -- not worthbbb
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.diagnostics.virtual_text = false
    end,
  },
}
