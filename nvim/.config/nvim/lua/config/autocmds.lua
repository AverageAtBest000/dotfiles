-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Matugen sends SIGUSR1 after regenerating its palette. Schedule the reload so
-- it happens outside the signal handler and only touches the active theme.
local matugen_group = vim.api.nvim_create_augroup("matugen_reload", { clear = true })

vim.api.nvim_create_autocmd("Signal", {
  group = matugen_group,
  pattern = "SIGUSR1",
  callback = function()
    if vim.g.colors_name == "matugen" then
      vim.schedule(function()
        vim.cmd.colorscheme("matugen")
      end)
    end
  end,
})
