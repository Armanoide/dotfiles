return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          swift = { "swiftformat" },
          rust = { "rustfmt" },
          javascript = { "prettierd", "prettier", stop_after_first = true },
          lua = { "stylua" },
          prisma = { "lsp" },
        },
        -- Optional: This ensures it formats on save
        format_on_save = {
          lsp_fallback = true,
          timeout_ms = 500,
        },
        log_level = vim.log.levels.ERROR,
      })
    end,
  },
}
