return {
  {
    "mbbill/undotree",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>h", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree" },
    },
  }
}
