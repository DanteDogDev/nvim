return {
  { "Civitasv/cmake-tools.nvim", enabled = false }, -- not worthbbb
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false,
      },
    },
  },
}
