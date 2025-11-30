return {
  {
    -- disabled because taking to much time to load
    enabled = false,
    "oribarilan/lensline.nvim",
    event = "LspAttach",
    config = function()
      require("lensline").setup({
        -- Profile definitions, first is default
        profiles = {
          {
            name = "basic",
            providers = {
              { name = "references",  enabled = true },
              { name = "last_author", enabled = false },
            },
            style = { render = "all", placement = "above" },
          },
          {
            name = "informative",
            providers = {
              { name = "references",  enabled = true },
              { name = "diagnostics", enabled = false, min_level = "HINT" },
              { name = "complexity",  enabled = false },
            },
            style = { render = "focused", placement = "inline" },
          },
        },
      })
    end,
  },
}
