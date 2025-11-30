return {
  {
    "nvim-treesitter/playground",
    cmd = "TSPlaygroundToggle", -- lazy load only when you run the command
    dependencies = "nvim-treesitter/nvim-treesitter",
  },
  {
    "nvim-mini/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),

          r = ai.gen_spec.treesitter({ a = "@return.outer", i = "@return.inner" }),     -- function
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),       -- class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },           -- tags
          d = { "%f[%d]%d+" },                                                          -- digits
          e = {                                                                         -- Word with case
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          g = LazyVim.mini.ai_buffer,                                -- buffer
          u = ai.gen_spec.function_call(),                           -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
      LazyVim.on_load("which-key.nvim", function()
        vim.schedule(function()
          LazyVim.mini.ai_whichkey(opts)
        end)
      end)
    end,
  },
  {
    "nvim-mini/mini.move",
    lazy = false,
    config = function()
      require("mini.move").setup({
        mappings = {
          right = "<M-l>",
          left = "<M-h>",
          up = "<M-k>",
          down = "<M-j>",
          line_left = "<M-h>",
          line_down = "<M-j>",
        },
        options = {
          reindent_linewise = true,
        },
      })
    end,
  },
  {
    'nvim-mini/mini.surround',
    version = false,
    event = 'VeryLazy',
    config = function()
      local ms = require('mini.surround')

      ms.setup({
        mappings = {
          add = 'gsa',       -- Add surrounding in Normal/Visual
          delete = 'gsd',    -- Delete surrounding (Normal only by default)
          find = 'gsf',      -- Find surrounding (to the right)
          find_left = 'gsF', -- Find surrounding (to the left)
          highlight = 'gsh', -- Highlight surrounding
          replace = 'gsr',   -- Replace surrounding (Normal only by default)
        },
      })

      -- Extend to Visual mode for delete/replace
      vim.keymap.set('x', 'gsd', function()
        ms.delete()
      end, { desc = 'Delete surrounding (Visual)' })

      vim.keymap.set('x', 'gsr', function()
        ms.replace()
      end, { desc = 'Replace surrounding (Visual)' })

      -- register with which-key so it's grouped under `gs`
      local ok, wk = pcall(require, 'which-key')
      if ok then
        wk.add({
          { "gs",  group = "Surround" },
          { "gsa", desc = "Add surrounding" },
          { "gsd", desc = "Delete surrounding" },
          { "gsf", desc = "Find right surrounding" },
          { "gsF", desc = "Find left surrounding" },
          { "gsh", desc = "Highlight surrounding" },
          { "gsr", desc = "Replace surrounding" },
          { "gsn", desc = "Update n_lines" },
        }, { mode = { "n", "x" } })
      end
    end,
  }

}
