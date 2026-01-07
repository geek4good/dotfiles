return {
  "ravitemer/mcphub.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  build = "pnpm add -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
  config = function()
    require("mcphub").setup({
      --- `mcp-hub` binary related options ---------------------
      config = vim.fn.expand("~/.config/mcphub/servers.json"),
      port = 37373,
      shutdown_delay = 60 * 10 * 1000, -- in ms
      use_bundled_binary = false, -- use local `mcp-hub` binary
      mcp_request_timeout = 60 * 1000, -- in ms

      --- Chat-plugin related options --------------------------
      auto_approve = false, -- auto_approve mp tool calls
      auto_toggle_mcp_servers = true, -- let LLMs start and stop MCP servers
      extensions = {
        avante = {
          make_slash_commands = true,
        },
      },

      --- Plugin specific options ------------------------------
      native_servers = {},
      ui = {
        window = {
          width = 0.8,
          height = 0.8,
          align = "center",
          relative = "editor",
          zindex = 50,
          border = "rounded",
        },
        wo = { -- window-scoped option (vim.wo)
          winhl = "Normal:MCPHubNormal,FloatBorder:MCPHubBorder",
        },
      },
      on_ready = function(hub)
        -- called when hub is ready
      end,
      on_error = function(hub)
        -- called on errors
      end,
      log = {
        level = vim.log.levels.WARN,
        to_file = false,
        file_path = nil,
        prefix = "MCPHub",
      },
    })
  end,
}
