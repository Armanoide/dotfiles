return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "catppuccin/nvim" },
    opts = {
      options = {
        theme                = "catppuccin",
        component_separators = { left = "", right = "" }, -- rounded small
        section_separators   = { left = "", right = "" }, -- rounded big
      },
      sections = {
        lualine_z = {}
      }
    },
  }
}
