return {
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
    opts = {
      features = {
        lsp = {
          enabled = true,
          on_attach = function(client, bufnr)
            local lsp_map = function(mode, keys, func, desc)
              vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
            end
            lsp_map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
            lsp_map("n", "gr", vim.lsp.buf.references, "Goto References")
            lsp_map("n", "ra", vim.lsp.buf.rename, "Rename")
            lsp_map("n", "K", vim.lsp.buf.hover, "Hover Docs")
          end,
        },
      },
      formatter = {
        enabled = true,
        tool = "swiftformat",
      },
    },
  },

  -- This handles building, testing, and project management
  {
    "wojciech-kulik/xcodebuild.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("xcodebuild").setup({
        integrations = {
          xcodebuild_offline_search = true,
          sourcekit = {
            enabled = true,
          },
        },
      })

      local map = vim.keymap.set
      map("n", "<leader>cx", "", { desc = "xcodebuild" })
      map("n", "<leader>cxb", "<cmd>XcodebuildBuild<cr>", { desc = "Build Project" })
      map("n", "<leader>cxr", "<cmd>XcodebuildRun<cr>", { desc = "Run Project" })
      map("n", "<leader>cxt", "<cmd>XcodebuildTest<cr>", { desc = "Run Tests" })
      map("n", "<leader>cxp", "<cmd>XcodebuildPicker<cr>", { desc = "Show Project Picker" })
      map("n", "<leader>cxs", "<cmd>XcodebuildSetup<cr>", { desc = "Setup Project" })
    end,
  },
}
