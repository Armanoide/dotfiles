return {
  -- Rust syntax support
  {
    "rust-lang/rust.vim",
    ft = "rust",
    init = function()
      vim.g.rustfmt_autosave = 1
    end,
  },

  -- Shows crate versions, updates, and docs inline in Cargo.toml
  {
    "saecki/crates.nvim",
    tag = "stable",
    ft = { "toml" },
    config = function()
      require("crates").setup({
        completion = {
          cmd = {
            enable = true,
          },
        },
      })
    end,
  },
  { "arzg/vim-rust-syntax-ext" },

  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    ft = "rust",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    opts = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            diagnostics = { enable = true },
            checkOnSave = { command = "clippy" },
          },
        },
      },
    },
    config = function(_, opts)
      -- Setup Debugger Paths
      local codelldb_path = vim.fn.exepath("codelldb")
      local liblldb_path = vim.fn.expand("$MASON/packages/codelldb/extension/lldb/lib/liblldb.dylib")

      -- If on Linux, change .dylib to .so
      if vim.loop.os_uname().sysname ~= "Darwin" then
        liblldb_path = vim.fn.expand("$MASON/packages/codelldb/extension/lldb/lib/liblldb.so")
      end

      local cfg = require("rustaceanvim.config")
      vim.g.rustaceanvim = vim.tbl_deep_extend("force", opts, {
        dap = {
          adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
        },
      })
    end,
    -- Custom Keymaps (Fixed the "Command not found" error by using keys)
    keys = {
      { "K", "<cmd>RustLsp { 'hover', 'actions' }<cr>", desc = "Rust Hover Docs" },
      { "<leader>cwa", "<cmd>RustLsp codeAction<cr>", desc = "Rust Code Action" },
      { "<leader>cwe", "<cmd>RustLsp explainError<cr>", desc = "Rust Error Explain" },
      { "<leader>cwd", "<cmd>RustLsp openDocs<cr>", desc = "Rust Docs" },
      { "<leader>cwm", "<cmd>RustLsp expandMacro<cr>", desc = "Rust Expand Macro" },
    },
  },
}
