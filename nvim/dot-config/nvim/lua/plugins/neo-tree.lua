return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<CMD>Neotree toggle<CR>", desc = "Explorer (Neo-tree)" },
    },
    init = function()
      if vim.fn.argc(-1) ~= 1 then
        return
      end
      local arg = vim.fn.argv(0)
      local stat = vim.loop.fs_stat(arg)
      if not stat or stat.type ~= "directory" then
        return
      end
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("user_neotree_startup", { clear = true }),
        once = true,
        callback = function()
          local prev_buf = vim.api.nvim_get_current_buf()
          vim.cmd("enew")
          if prev_buf ~= vim.api.nvim_get_current_buf() then
            pcall(vim.api.nvim_buf_delete, prev_buf, { force = true })
          end
          vim.cmd("tcd " .. vim.fn.fnameescape(arg))
          local editor_win = vim.api.nvim_get_current_win()
          vim.cmd("Neotree show")
          pcall(vim.api.nvim_set_current_win, editor_win)
        end,
      })
    end,
    opts = {
      filesystem = {
        hijack_netrw_behavior = "disabled",
      },
      window = {
        position = "left",
        width = 30,
      },
    },
  },
  {
    "stevearc/oil.nvim",
    version = "0.10",
    lazy = false,
    opts = {
      default_file_explorer = false,
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
    },
  },
}
