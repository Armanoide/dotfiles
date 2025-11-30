return {
  "m4xshen/hardtime.nvim",
  events = { "BufEnter" },
  commands = { "Hardtime" },
  dependencies = { "MunifTanjim/nui.nvim" },
  config = function(_, opts)
    require("hardtime").setup(opts)
  end,
}
