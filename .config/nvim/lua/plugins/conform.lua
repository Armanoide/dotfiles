return {
  {
    "stevearc/conform.nvim",
    -- LazyVim owns conform's config; use opts so our settings merge with theirs
    opts = {
      formatters_by_ft = {
        swift = { "swiftformat" },
        rust = { "rustfmt" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        lua = { "stylua" },
        prisma = { "lsp" },
      },
      format_on_save = {
        lsp_fallback = true,
        timeout_ms = 500,
      },
    },
  },
}
