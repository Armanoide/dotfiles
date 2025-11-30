return {
  "karb94/neoscroll.nvim",
  config = function()
    local neoscroll = require("neoscroll")

    -- Setup with performance mode
    neoscroll.setup({
      -- performance_mode = true,
    })

    local keymap = {
      ["<D-u>"] = function() neoscroll.ctrl_u({ duration = 450 }) end,
      ["<D-d>"] = function() neoscroll.ctrl_d({ duration = 450 }) end,
    }

    local modes = { "n", "i", "v", "c" }
    for key, func in pairs(keymap) do
      vim.keymap.set(modes, key, func, { silent = true })
    end
  end
}
