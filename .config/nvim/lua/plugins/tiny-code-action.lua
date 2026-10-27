return {
    "rachartier/tiny-code-action.nvim",
    dependencies = {
        {"nvim-telescope/telescope.nvim"},
        {"ibhagwan/fzf-lua"},
        {
          "folke/snacks.nvim",
          opts = {
            terminal = {},
          }
        }
    },
    event = "LspAttach",
    opts = {},
}
