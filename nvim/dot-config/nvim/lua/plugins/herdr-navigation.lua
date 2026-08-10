return {
  -- Seamless <C-h/j/k/l> navigation between Neovim splits and Herdr panes.
  -- Herdr side is installed via `herdr plugin install paulbkim-dev/vim-herdr-navigation`;
  -- this loads the editor-side keymaps (editor/nvim.lua) that hand off to Herdr
  -- at split edges, and fall back to tmux/plain wincmd outside Herdr.
  --
  -- LazyVim ships its own <C-h/j/k/l> = <C-w>h/j/k/l ("Go to … Window") keymaps
  -- which load AFTER this plugin's config and would overwrite the handoff. We load
  -- on the VeryLazy event (fired after LazyVim's core keymaps) so our mappings win.
  -- No deletion: if the dofile ever fails, LazyVim's plain-wincmd maps remain.
  {
    "paulbkim-dev/vim-herdr-navigation",
    lazy = false,
    config = function()
      local file = vim.fn.stdpath("data") .. "/lazy/vim-herdr-navigation/editor/nvim.lua"
      vim.api.nvim_create_autocmd("User", {
        once = true,
        pattern = "VeryLazy",
        callback = function()
          if vim.fn.filereadable(file) == 1 then
            dofile(file)
          end
        end,
      })
    end,
  },
}
