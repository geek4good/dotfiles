return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd><C-U>TmuxNavigateLeft<CR>", desc = "Navigate Left (tmux)" },
      { "<C-j>", "<cmd><C-U>TmuxNavigateDown<CR>", desc = "Navigate Down (tmux)" },
      { "<C-k>", "<cmd><C-U>TmuxNavigateUp<CR>", desc = "Navigate Up (tmux)" },
      { "<C-l>", "<cmd><C-U>TmuxNavigateRight<CR>", desc = "Navigate Right (tmux)" },
      { "<C-\\>", "<cmd><C-U>TmuxNavigatePrevious<CR>", desc = "Navigate Previous (tmux)" },
    },
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
  },
}
