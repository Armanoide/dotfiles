return {
  "mason-org/mason-lspconfig.nvim",
  config = function()
    require("mason-lspconfig").setup {
      automatic_enable = {
        exclude = {
          -- manage by check plugin/rust.lua
          "rust_analyzer",
        }
      }
    }
  end,
}
