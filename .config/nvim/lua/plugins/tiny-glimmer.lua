return {
  {
    "rachartier/tiny-glimmer.nvim",
    event = "VeryLazy",
    priority = 10, -- Low priority to catch other plugins' keybindings
    -- if enabled, undo not working properly
    enabled = false,
    opts = {
      overwrite = {
        undo = { enabled = true },
        redo = { enabled = true },
        paste = { enabled = true },
      },
    },
  },
}
