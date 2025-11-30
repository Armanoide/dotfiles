return {
  -- Shows the current function/class scope at the top of the buffer using Treesitter
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function(_, opts)
      require("treesitter-context").setup(opts)
    end
  },
  -- Core Treesitter setup for syntax highlighting, indentation, incremental selection, and language parser management
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
      "windwp/nvim-ts-autotag",
    },
    opts = {
      highlight = {
        enable = true,
        under_cursor = true,
        disable = { "verilog", "systemverilog" }, -- list of languages to disable highlighting for
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = true,
      },
      -- enable indentation
      indent = { enable = true },
      -- enable autotagging (w/ nvim-ts-autotag plugin)
      autotag = {
        enable = true,
      },
      -- ensure these language parsers are installed
      ensure_installed = {
        "norg",
        "norg_meta",
        "json",
        "rust",
        "javascript",
        "typescript",
        "tsx",
        "yaml",
        "html",
        "css",
        "prisma",
        "markdown",
        "markdown_inline",
        "svelte",
        "graphql",
        "bash",
        "lua",
        "vim",
        "dockerfile",
        "gitignore",
        "query",
        "verilog",
      },
    },
  },
}
