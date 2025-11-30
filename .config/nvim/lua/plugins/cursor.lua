return {
  {
    "mvllow/modes.nvim",
    dir = "/Volumes/EXT1_SSD/Users/user1/Projects/Other/modes.nvim",
    config = function()
      require("modes").setup({
        colors = {
          normal  = "#89b4fa",
          insert  = "#a6e3a1",
          visual  = "#cba6f7",
          replace = "#eba0ac",
          delete  = "#d20f39",
          copy    = "#8839ef",
          format  = "#b4befe"
        },
        line_opacity = 0.4,
        set_cursor = true,
        set_cursorline = false,
        set_signcolumn = false,
      })
    end,
  },
  --   enabled = true,
  --   "mvllow/modes.nvim",
  --   dir = "/Volumes/EXT1_SSD/Users/user1/Projects/Other/modes.nvim",
  --   opts = {
  --     colors = {
  --       insert = "#66a4e7",
  --       normal = "#98bc74",
  --       visual = "#b36cd3",
  --       copy = "#f5c359",
  --       delete = "#c75c6a",
  --       replace = "#245361",
  --       change = "#c75c6a", -- Optional param, defaults to delete
  --       format = "#c79585",
  --     },
  --     -- Set opacity for cursorline and number background
  --     line_opacity = 0.15,
  --
  --     -- Enable cursor highlights
  --     set_cursor = true,
  --
  --     -- Enable cursorline initially, and disable cursorline for inactive windows
  --     -- or ignored filetypes
  --     set_cursorline = false,
  --
  --     -- Enable sign column highlights to match cursorline
  --     set_signcolumn = false,
  --
  --
  --   }
  -- }
}
