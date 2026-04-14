return {
  -- Disable NeoTree
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },

  -- Use Oil as the default file explorer
  {
    "stevearc/oil.nvim",
    version = "0.10",
    lazy = false,
    opts = {
      default_file_explorer = true,
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
    },
  },
}
