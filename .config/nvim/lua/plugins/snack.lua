return {
  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = false },
      explorer = { enabled = false}
    },
    config = function(_, opts)
      require("snacks").setup(opts)
    end,
  },
}
