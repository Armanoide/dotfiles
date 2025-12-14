return {
  -- 1. Add dependencies
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "saghen/blink.cmp" }, -- Using blink.cmp as requested
      { "antosha417/nvim-lsp-file-operations", config = true },
    },
    opts = {
      -- Disable virtual text (inline errors) as per your first snippet
      diagnostics = {
        virtual_text = false,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
      },
      -- Customizing the Sourcekit Server
      servers = {
        sourcekit = {
          -- This command dynamically finds your Xcode's sourcekit path
          cmd = { vim.trim(vim.fn.system("xcrun -f sourcekit-lsp")) },
          root_dir = function(filename, _)
            local util = require("lspconfig.util")
            return util.root_pattern("Package.swift", ".git")(filename)
          end,
        },
      },
      setup = {
        sourcekit = function()
          -- Setup icons for diagnostics
          local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
          for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
          end
        end,
      },
    },
  },
}
