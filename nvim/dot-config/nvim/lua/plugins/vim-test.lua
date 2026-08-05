return {
  "vim-test/vim-test",
  init = function()
    -- Run tests in a :terminal buffer (no tmux needed)
    vim.g["test#strategy"] = "neovim"

    require("which-key").add({
      { "<leader>t", group = "test" },
    })
  end,
  keys = {
    { "<leader>tt", "<cmd>TestNearest<CR>", desc = "Run nearest test" },
    { "<leader>tT", "<cmd>TestFile<CR>", desc = "Run whole file" },
    { "<leader>ta", "<cmd>TestSuite<CR>", desc = "Run all tests" },
    { "<leader>tl", "<cmd>TestLast<CR>", desc = "Re-run last test(s)" },
    { "<leader>tg", "<cmd>TestVisit<CR>", desc = "Visit last test file" },
  },
}