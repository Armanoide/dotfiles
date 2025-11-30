-- setup must be called before loading
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        treesitter = true,
        native_lsp = { enabled = true },
        mason = true,
        which_key = true,
        noice = true,
        lsp_trouble = true,
        nvimtree = true,
      },
    }
  },
}
