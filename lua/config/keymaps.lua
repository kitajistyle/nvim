-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Command+P: VS Code と同じファイル検索 (GUI / Neovide で動作)
vim.keymap.set("n", "<D-p>", function() Snacks.picker.files() end, { desc = "Find Files" })
