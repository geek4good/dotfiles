return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration

      "nvim-telescope/telescope.nvim",
    },
    config = true,
    keys = {
      { "<leader>gg", "<cmd>Neogit cwd=%:p:h<cr>", desc = "Neogit (cwd)" },
      { "<leader>gG", "<cmd>Neogit<cr>", desc = "Neogit (root dir)" },
      { "<leader>gs", "<cmd>Neogit cwd=%:p:h<cr>", desc = "Git Status" },
    },
  },
}
