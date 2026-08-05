-- Per-project Ruby formatter: auto-detect standardrb vs rubocop from
-- Gemfile.lock, and run through `bundle exec` so it uses the exact gem
-- version pinned in the project's lock file (same as CI).

---Check if a gem is listed in the project's Gemfile.lock specs.
---@param bufnr integer
---@param gem string
---@return boolean
local function has_gem(bufnr, gem)
  local path = vim.api.nvim_buf_get_name(bufnr)
  local root = vim.fs.root(path, { "Gemfile.lock" })
  if not root or vim.fn.filereadable(root .. "/Gemfile.lock") ~= 1 then
    return false
  end
  for _, line in ipairs(vim.fn.readfile(root .. "/Gemfile.lock")) do
    -- Gemfile.lock spec lines look like: "    standard (1.43.0)"
    if line:match("^%s+" .. gem .. "%s+%(") then
      return true
    end
  end
  return false
end

return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      -- Pick standardrb or rubocop based on which gem the project bundles.
      opts.formatters_by_ft.ruby = function(bufnr)
        if has_gem(bufnr, "standard") then
          return { "standardrb" }
        elseif has_gem(bufnr, "rubocop") then
          return { "rubocop" }
        end
        -- No Gemfile.lock or neither gem found → use global default.
        return { vim.g.lazyvim_ruby_formatter or "standardrb" }
      end

      -- Prepend `bundle exec` so the formatter runs with the exact version
      -- from Gemfile.lock, matching CI. Falls back to the bare binary
      -- (mise-managed) when the gem isn't bundled.
      opts.formatters = opts.formatters or {}

      opts.formatters.rubocop = function(bufnr)
        if has_gem(bufnr, "rubocop") then
          return {
            command = "bundle",
            prepend_args = { "exec", "rubocop" },
          }
        end
      end

      opts.formatters.standardrb = function(bufnr)
        if has_gem(bufnr, "standard") then
          return {
            command = "bundle",
            prepend_args = { "exec", "standardrb" },
          }
        end
      end
    end,
  },
}
