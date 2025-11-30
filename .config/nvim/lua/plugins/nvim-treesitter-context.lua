return {
  "nvim-treesitter/nvim-treesitter-context",
  config = function(_, opts)
    require("treesitter-context").setup {
      max_lines = 1,
      trim_scope = "inner",
    }
  end
}
