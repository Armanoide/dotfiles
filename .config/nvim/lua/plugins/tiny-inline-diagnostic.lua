return {

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
      vim.diagnostic.config({ virtual_text = false, virtual_lines = false, underline = false, undercurl = true })
      require("tiny-inline-diagnostic").setup()
    end,
  },
}
