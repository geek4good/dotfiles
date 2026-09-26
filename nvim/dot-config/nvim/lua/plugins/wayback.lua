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
      {
        "<leader>gt",
        function()
          local orig_buf = vim.api.nvim_get_current_buf()
          require("wayback").timelapse()
          -- Upstream quirk: wayback's quit deletes the timelapse buffer, which closes
          -- the pane (nvim_win_set_buf sets no alternate). Restore the original
          -- buffer before deleting, so the pane survives.
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_get_name(b):match("^wayback://timelapse") then
              local quit_key = require("wayback.config").values.timelapse.quit
              vim.keymap.set("n", quit_key, function()
                if vim.api.nvim_buf_is_valid(orig_buf) then
                  for _, w in ipairs(vim.fn.win_findbuf(b)) do
                    pcall(vim.api.nvim_win_set_buf, w, orig_buf)
                  end
                end
                if vim.api.nvim_buf_is_valid(b) then
                  vim.api.nvim_buf_delete(b, { force = true })
                end
              end, { buffer = b, desc = "Wayback: exit timelapse (restore pane)" })
            end
          end
        end,
        desc = "Wayback timelapse",
      },
    },
    opts = {
      picker = "snacks", -- deterministic; matches LazyVim's native picker (telescope is only here as a neogit dep)
    },
  },
}
