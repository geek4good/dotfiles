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
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_get_name(b):match("^wayback://timelapse") then
              local t = require("wayback.config").values.timelapse
              local saved_winbar = {}

              -- Mirror the plugin's header extmark into the winbar. The built-in
              -- virt line above row 0 scrolls away with the buffer; the winbar
              -- keeps [i/N] + hash visible at all times. Reads the
              -- "wayback_timelapse" namespace -- same coupling class as the
              -- pane fix below.
              local ns = vim.api.nvim_create_namespace("wayback_timelapse")
              local function mirror()
                local mark = vim.api.nvim_buf_get_extmarks(b, ns, 0, -1, { details = true })[1]
                local text = mark and mark[4] and mark[4].virt_lines
                  and mark[4].virt_lines[1] and mark[4].virt_lines[1][1] and mark[4].virt_lines[1][1][1]
                if not text then
                  return
                end
                text = text:gsub("%%", "%%%%") -- winbar strings interpret %X sequences
                for _, w in ipairs(vim.fn.win_findbuf(b)) do
                  saved_winbar[w] = saved_winbar[w] or vim.wo[w].winbar
                  vim.wo[w].winbar = "%#SpecialChar# " .. text
                end
              end

              -- Chain next/prev so each step also refreshes the winbar.
              for _, key in ipairs({ t.next, t.prev }) do
                for _, m in ipairs(vim.api.nvim_buf_get_keymap(b, "n")) do
                  if vim.fn.keytrans(m.lhs) == vim.fn.keytrans(key) and m.callback then
                    local orig_cb = m.callback
                    vim.keymap.set("n", key, function()
                      orig_cb()
                      mirror()
                    end, { buffer = b, desc = m.desc })
                    break
                  end
                end
              end
              mirror()

              -- Upstream quirk: wayback's quit deletes the timelapse buffer, which closes
              -- the pane (nvim_win_set_buf sets no alternate). Restore the original
              -- buffer before deleting, so the pane survives; restore the winbar too.
              vim.keymap.set("n", t.quit, function()
                if vim.api.nvim_buf_is_valid(orig_buf) then
                  for _, w in ipairs(vim.fn.win_findbuf(b)) do
                    if saved_winbar[w] ~= nil then
                      vim.wo[w].winbar = saved_winbar[w]
                    end
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
