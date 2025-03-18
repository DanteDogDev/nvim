-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local function mapkey(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end
local function nmap(lhs, rhs, opts)
  mapkey("n", lhs, rhs, opts)
end
local function vmap(lhs, rhs, opts)
  mapkey("v", lhs, rhs, opts)
end
local function map(lhs, rhs, opts)
  nmap(lhs, rhs, opts)
  vmap(lhs, rhs, opts)
end

map("x", '"_x')
map("ciw", '"_ciw')

map("gh", "^", { desc = "Start of line" })
map("gl", "$", { desc = "End of line" })
