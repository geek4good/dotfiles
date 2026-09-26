return {
  "dlyongemallo/diffview-plus.nvim",
  version = "*",
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
    { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
    { "<leader>gfh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History" },
  },
  opts = {
    view = {
      merge_tool = { layout = "diff3_horizontal" }, -- LOCAL | BASE | REMOTE | merged
    },
  },
}
