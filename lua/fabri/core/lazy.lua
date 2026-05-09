local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- Manually prepend treesitter to rtp before lazy.setup runs
-- This fixes a Windows/Scoop timing issue where lazy loads the plugin
-- but doesn't add it to rtp before calling its config
local ts_path = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter"
if vim.loop.fs_stat(ts_path) then
  vim.opt.rtp:prepend(ts_path)
end

require("lazy").setup({
  spec = {
    { import = "fabri.plugins" },
  },
  defaults = {
    lazy = false,
  },
  install = {
    colorscheme = { "gruvbox", "habamax" },
  },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
  performance = {
    cache = {
      enabled = false,
    },
  },
})
