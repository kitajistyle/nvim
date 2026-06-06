return {
  -- snacks_picker extra が <leader>gd / <leader>gD を使うので diffview 側を優先
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>gd", false },
      { "<leader>gD", false },
    },
  },

  -- gitsigns: LazyVim が既に含む。キーマップのみ補足設定
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        map("n", "]h", function() gs.nav_hunk("next") end, "Next Hunk")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Prev Hunk")

        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>",  "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>",  "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer,      "Stage Buffer")
        map("n", "<leader>ghR", gs.reset_buffer,      "Reset Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk,   "Undo Stage Hunk")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
      end,
    },
  },

  -- neogit: コミット・プッシュ・全体ステータス
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    cmd = "Neogit",
    keys = {
      { "<leader>gn", "<cmd>Neogit<cr>",        desc = "Neogit" },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit Commit" },
    },
    opts = {
      integrations = { diffview = true },
      commit_editor = { kind = "split" },
      kind = "tab",
    },
  },

  -- diffview: コードレビュー・履歴確認・コンフリクト解消
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>",           desc = "Diffview Open" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>",          desc = "Diffview Close" },
      { "<leader>gl", "<cmd>DiffviewFileHistory %<cr>",  desc = "File History (current)" },
      { "<leader>gL", "<cmd>DiffviewFileHistory<cr>",    desc = "File History (repo)" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = { layout = "diff3_mixed" },
      },
      file_panel = {
        listing_style = "tree",
        win_config = { width = 35 },
      },
      hooks = {
        view_closed = function(view)
          if view.class.name == "DiffView" then
            vim.cmd("tabclose")
          end
        end,
      },
    },
  },
}
