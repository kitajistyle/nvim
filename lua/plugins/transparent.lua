return {
  "xiyaowong/transparent.nvim",
  lazy = false,
  config = function()
    require("transparent").setup({
      enable_on_startup = true,
      extra_groups = {
        "NormalFloat",
        "NvimTreeNormal", "NvimTreeNormalNC",
        "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer",
        "TelescopeNormal", "TelescopeBorder",
        "TelescopePromptBorder", "TelescopeResultsBorder",
        "TelescopePreviewBorder",
        "SignColumn", "EndOfBuffer",
        "LineNr", "CursorLineNr", "FoldColumn",
        "StatusLine", "StatusLineNC",
        "TabLine", "TabLineFill", "TabLineSel",
        "WinBar", "WinBarNC",
      },
    })
  end,
}
