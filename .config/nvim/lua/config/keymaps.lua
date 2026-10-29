-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Save file with Cmd+S (Mac)
vim.api.nvim_set_keymap("n", "<D-s>", ":w<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<D-s>", "<Esc>:w<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>f/", function()
  require("snacks.picker").grep({
    buffers = { vim.api.nvim_get_current_buf() },
  })
end, { desc = "Search in current file" })

vim.keymap.set("n", "<leader>wt", function()
  -- Open terminal in a split, starting in current cwd
  local file_dir = vim.fn.expand("%:p:h")
  if file_dir == "" then
    file_dir = vim.loop.cwd() -- fallback if no file is open
  end

  vim.cmd("belowright split")
  vim.cmd("lcd " .. file_dir) -- make the split's cwd the global cwd
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, { desc = "Open Terminal in cwd" })
map("t", "<C-z>", "<C-\\><C-n>", { desc = "Terminal Normal Mode" })
