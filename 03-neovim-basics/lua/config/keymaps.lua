--- lua/config/keymaps.lua — 配置拆分参考：所有 vim.keymap.set 键位设置
---
--- 部署参考文件（同 options.lua），真实部署时在 init.lua 里 require("config.keymaps")

-- ============================================================
-- 保存与退出
-- ============================================================

vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "保存文件" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "退出" })
vim.keymap.set("n", "<leader>x", "<cmd>x<CR>", { desc = "保存并退出" })

-- ============================================================
-- 窗口导航（Ctrl + hjkl，比 Ctrl-w hjkl 更顺手）
-- ============================================================

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "移到左窗口" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "移到下窗口" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "移到上窗口" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "移到右窗口" })

-- 窗口分屏快捷键
vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "垂直分屏" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<CR>", { desc = "水平分屏" })
vim.keymap.set("n", "<leader>so", "<cmd>only<CR>", { desc = "只留当前窗口" })

-- ============================================================
-- 缓冲区切换
-- ============================================================

vim.keymap.set("n", "<S-l>", "<cmd>bn<CR>", { desc = "下一个缓冲区" })
vim.keymap.set("n", "<S-h>", "<cmd>bp<CR>", { desc = "上一个缓冲区" })
vim.keymap.set("n", "<leader>bd", "<cmd>bd<CR>", { desc = "关闭缓冲区" })

-- ============================================================
-- 搜索
-- ============================================================

vim.keymap.set("n", "<leader>nh", "<cmd>noh<CR>", { desc = "清除搜索高亮" })

-- ============================================================
-- 视觉行移动（长行换行时按屏幕行跳）
-- ============================================================

vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "下移（视觉行）" })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "上移（视觉行）" })

return nil
