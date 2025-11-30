-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Fix tmux (scroll display)
vim.opt.termguicolors = true

-- Disable LazyVim plugin load order checks (for override the dashboard)
vim.g.lazyvim_check_order = false

-- Enable automatic code formatting on save
vim.g.autoformat = true

-- Use the system clipboard for all yank, delete, change, and put operations
-- (makes Vim share the same clipboard as macOS/Linux/Windows)
vim.opt.clipboard = "unnamedplus"

-- Configure LazyVim’s Rust integration to use rust-analyzer for diagnostics
-- (default LSP engine for Rust, ensures proper error reporting & analysis)
vim.g.lazyvim_rust_diagnostics = "rust-analyser"

-- Disable swap files to avoid .swp recovery prompts
vim.opt.swapfile = false

-- Enable backup: keep a copy of the file before overwriting
vim.opt.backup = true

-- Write backup before overwriting the file (safer, avoids data loss if crash)
vim.opt.writebackup = true

-- Directory where backup files will be stored
-- (using Neovim’s standard state path, usually ~/.local/state/nvim/backup)
vim.opt.backupdir = vim.fn.stdpath("state") .. "/backup"

-- Set cursor style to block in all the modes
vim.opt.guicursor = "n-v-c:block,i-ci-ve:block,r-cr-o:block"

-- Disable highlighting of the word under the cursor
vim.g.cursorword = false

-- Filetype detection for .env files
vim.filetype.add({
  extension = {
    env = "sh",
  },
  filename = {
    [".env"] = "sh",
  },
  pattern = {
    ["%.env%.[%w_.-]+"] = "sh",
  },
})

-- persistent undo: enable undo history across sessions
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
