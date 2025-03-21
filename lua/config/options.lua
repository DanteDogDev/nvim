-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.termguicolors = true
vim.opt.colorcolumn = "120"
vim.opt.scrolloff = 10
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.o.foldmethod = "marker"
vim.o.foldmarker = "#pragma region,#pragma endregion"
