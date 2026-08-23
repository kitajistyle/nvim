return {
  -- VSCode 風カラーテーマプラグインの追加
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = false, -- 背景を透明にする場合は true
      italic_comments = true,
      underline_links = true,
      color_overrides = {},
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "vscode",
    },
  },
}
