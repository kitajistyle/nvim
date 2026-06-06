-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- フォーカスが外れたとき・Insert を抜けたときに自動保存
vim.api.nvim_create_autocmd({ "FocusLost", "InsertLeave", "TextChanged" }, {
  pattern = "*",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].modified and vim.bo[buf].buftype == "" and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! write")
    end
  end,
})

-- 起動時・カラースキーム変更時に背景を透明化してターミナルの半透明を透過させる
vim.api.nvim_create_autocmd({ "UIEnter", "ColorScheme" }, {
  pattern = "*",
  callback = function()
    local groups = {
      "Normal", "NormalNC", "NormalFloat",
      "SignColumn", "EndOfBuffer", "LineNr", "CursorLineNr",
      "FoldColumn", "StatusLine", "StatusLineNC",
      "TabLine", "TabLineFill", "TabLineSel",
      "WinBar", "WinBarNC",
      "NeoTreeNormal", "NeoTreeNormalNC",
      "NeoTreeEndOfBuffer",
      "TelescopeNormal", "TelescopeBorder",
      "TelescopePromptBorder", "TelescopeResultsBorder",
      "TelescopePreviewBorder",
    }
    for _, group in ipairs(groups) do
      vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
    end
  end,
})
