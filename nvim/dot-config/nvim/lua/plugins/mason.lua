-- Use mise-managed Ruby tools instead of Mason.
-- Mason installs Ruby gems with hardcoded interpreter shebangs that break on
-- every Ruby update ("bad interpreter: No such file"). mise shims are dynamic.
return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      opts.ensure_installed = vim.tbl_filter(function(pkg)
        return not vim.list_contains({ "erb-formatter", "erb-lint", "standardrb", "ruby-lsp", "rubocop" }, pkg)
      end, opts.ensure_installed)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruby_lsp = { mason = false },
        -- ruby_lsp natively runs the project's linter (RuboCop/Standard)
        -- using its own config (e.g. rubocop-rails-omakase), so the extra
        -- standardrb/rubocop LSP servers are disabled to avoid duplicate or
        -- conflicting hints. Formatting is handled per-project by conform.
        standardrb = { mason = false, enabled = false },
        rubocop = { mason = false, enabled = false },
      },
    },
  },
}
