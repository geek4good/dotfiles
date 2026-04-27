-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_ruby_formatter = "standardrb"

if vim.g.neovide then
  vim.o.guifont = "Iosevka NF:h20"
end
