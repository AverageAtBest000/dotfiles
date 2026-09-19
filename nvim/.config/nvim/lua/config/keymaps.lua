-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here


-- j for scrolling down and k for up
local map = vim.keymap.set

map({ "n", "v", "o" }, "j", "k", { desc = "Move cursor up" })
map({ "n", "v", "o" }, "k", "j", { desc = "Move cursor down" })

map({ "n", "v", "o" }, "gj", "gk", { desc = "Move up display line" })
map({ "n", "v", "o" }, "gk", "gj", { desc = "Move down display line" })