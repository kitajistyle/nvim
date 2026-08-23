return {
  "folke/tokyonight.nvim",
  opts = {
    transparent = true,
    styles = {
      sidebars = "transparent",
      floats = "transparent",
    },
    on_highlights = function(hl)
      hl.WinSeparator = { fg = "#00ffff", bold = true }
      hl.VertSplit = { fg = "#00ffff", bold = true }
    end,
  },
}
