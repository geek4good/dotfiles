return {
  {
    "piersolenski/wayback.nvim",
    dependencies = {
      "tpope/vim-fugitive", -- open historical versions as fugitive objects (:Gblame, :Gdiffsplit)
    },
    cmd = { "Wayback", "WaybackHeatmap", "WaybackTimelapse" },
    keys = {
      { "<leader>gw", function() require("wayback").open() end, mode = { "n", "x" }, desc = "Wayback (file history)" },
      { "<leader>gH", function() require("wayback").heatmap() end, desc = "Wayback heatmap" },
      { "<leader>gt", function() require("wayback").timelapse() end, desc = "Wayback timelapse" },
    },
    opts = {
      picker = "snacks", -- deterministic; matches LazyVim's native picker (telescope is only here as a neogit dep)
      timelapse = {
        next = "<C-n>", -- newer version (was ]v)
        prev = "<C-p>", -- older version (was [v)
      },
    },
  },
}
