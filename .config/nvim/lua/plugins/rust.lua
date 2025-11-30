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

  -- Alternative Rust LSP (rustaceanvim)
  {
    "mrcjkb/rustaceanvim",
    version = "^6", -- recommended
    ft = "rust",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    config = function()
      local codelldb_path = vim.fn.exepath("codelldb")
      local liblldb_path = vim.fn.expand("$MASON/packages/codelldb/extension/lldb/lib/liblldb.dylib")

      local cfg = require("rustaceanvim.config")

      vim.g.rustaceanvim = {
        dap = {
          adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
        },
        server = {
          on_attach = function(_, bufnr)
            local lsp_map = function(mode, keys, func, desc)
              vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
            end
            -- rust-lsp mappings
            lsp_map("n", "<leader>ci", function()
              vim.cmd.rustlsp({ "hover", "actions" })
            end, "rust hover docs")
            lsp_map("n", "<leader>cj", function()
              vim.cmd.rustlsp("joinlines")
            end, "rust join lines")
            lsp_map("n", "<leader>cw", "<nop>", "rust commands")
            lsp_map("n", "<leader>cwa", function()
              vim.cmd.rustlsp("codeaction")
            end, "rust code action")
            lsp_map("n", "<leader>cwe", function()
              vim.cmd.rustlsp("explainerror")
            end, "rust error explain")
            lsp_map("n", "<leader>cwd", function()
              vim.cmd.rustlsp("opendocs")
            end, "rust docs")
            lsp_map("n", "<leader>cwm", function()
              vim.cmd.rustlsp("expandmacro")
            end, "rust expand macro")
            -- copy from lsp_config
            lsp_map("n", "gd", vim.lsp.buf.definition, "goto definition")
            lsp_map("n", "gd", vim.lsp.buf.declaration, "goto declaration")
            lsp_map("n", "gi", vim.lsp.buf.implementation, "goto implementation")
            lsp_map("n", "go", vim.lsp.buf.type_definition, "goto type definition")
            lsp_map("n", "gr", vim.lsp.buf.references, "goto references")
            lsp_map("n", "ra", vim.lsp.buf.rename, "rename")
          end,
          settings = {
            cargo = {
              allfeatures = true,
            },
            ["rust-analyzer"] = {
              diagnostics = { enable = true },
            },
          },
        },
      }
    end,
  },
}
