-- Make snippet templates (class/module/def/do/...) the pre-selected default
-- in the completion menu, so Enter accepts them directly without arrow-down.
--
-- blink.cmp penalizes snippet items twice by default:
--   providers.snippets.score_offset = -1  (provider-level)
--   snippets.score_offset           = -3  (top-level, applied to Snippet kind)
-- That ranks them below LSP (0) and path (+3) completions.
--
-- We lift the provider-level offset for Ruby buffers so the template wins the
-- top slot; elsewhere we keep blink's stock behavior to avoid hijacking
-- normal identifier completion in other languages.
return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    opts.sources = opts.sources or {}
    opts.sources.providers = opts.sources.providers or {}
    opts.sources.providers.snippets = opts.sources.providers.snippets or {}

    -- Boost enough to beat LSP (0) and path (+3), even after the
    -- top-level -3 snippet penalty (10 - 3 = +7 net for Ruby snippets).
    opts.sources.providers.snippets.score_offset = function(ctx)
      if vim.bo[ctx.bufnr].filetype == "ruby" then
        return 10
      end
      return 0
    end
  end,
}
