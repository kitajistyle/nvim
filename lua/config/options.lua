-- pumblend/winblend を 0 にしてウィンドウの独自半透明を無効化（ターミナル側の透明を生かす）
vim.opt.pumblend = 0
vim.opt.winblend = 0

-- 行番号を相対表示ではなく絶対（固定）表示にする
vim.opt.number = true
vim.opt.relativenumber = false
