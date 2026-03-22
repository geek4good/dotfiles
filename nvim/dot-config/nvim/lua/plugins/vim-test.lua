return {
  "vim-test/vim-test",
  dependencies = {
    "preservim/vimux",
  },
  vim.keymap.set("n", "<leader>tt", "<cmd>TestNearest<CR>", { desc = "Run nearest test" }),
  vim.keymap.set("n", "<leader>tT", "<cmd>TestFile<CR>", { desc = "Run whole file" }),
  vim.keymap.set("n", "<leader>ta", "<cmd>TestSuite<CR>", { desc = "Run all tests" }),
  vim.keymap.set("n", "<leader>tl", "<cmd>TestLast<CR>", { desc = "Re-run last test(s)" }),
  vim.keymap.set("n", "<leader>tg", "<cmd>TestVisit<CR>", { desc = "Visit last test file" }),
  vim.cmd("let test#strategy = 'vimux'"),
  init = function()
    require("which-key").add({
      { "<leader>t", group = "test" },
    })
  end,
}
