-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- vim.keymap.set({ "i", "n", "v","x" }, "<C-Space>", "<nop>")
-- vim.keymap.del("n", "<leader>gg")
-- vim.keymap.del("n", "<leader>gG")
-- vim.keymap.del("n", "<leader>gs")
vim.keymap.set("n", "<leader>fs", "<cmd>write<CR>", { desc = "Save File" })

vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "Navigate Left (tmux)" })
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "Navigate Down (tmux)" })
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "Navigate Up (tmux)" })
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "Navigate Right (tmux)" })
vim.keymap.set("n", "<C-\\>", "<cmd>TmuxNavigatePrevious<CR>", { desc = "Navigate Previous (tmux)" })
