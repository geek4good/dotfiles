-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- vim.keymap.set({ "i", "n", "v","x" }, "<C-Space>", "<nop>")
-- vim.keymap.del("n", "<leader>gg")
-- vim.keymap.del("n", "<leader>gG")
-- vim.keymap.del("n", "<leader>gs")
vim.keymap.set("n", "<leader>fs", "<cmd>write<CR>", { desc = "Save File" })

-- Window navigation: C-h/j/k/l moves between nvim splits
vim.keymap.set("n", "<C-h>", "<cmd>wincmd h<CR>", { desc = "Navigate Left" })
vim.keymap.set("n", "<C-j>", "<cmd>wincmd j<CR>", { desc = "Navigate Down" })
vim.keymap.set("n", "<C-k>", "<cmd>wincmd k<CR>", { desc = "Navigate Up" })
vim.keymap.set("n", "<C-l>", "<cmd>wincmd l<CR>", { desc = "Navigate Right" })
