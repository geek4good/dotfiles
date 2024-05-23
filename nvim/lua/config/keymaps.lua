-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- vim.keymap.set({ "i", "n", "v","x" }, "<C-Space>", "<nop>")
vim.keymap.set("n", "<leader>fs", "<cmd>write<CR>", { desc = "Save File" })
