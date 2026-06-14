--- lua/config/keymaps.lua — 全局快捷键示例（第18章）
---
--- LazyVim 会自动加载这个文件（在默认 keymaps 之后）。
--- 你可以在这里：新增、覆盖、删除快捷键。
---
--- ⚠️ 铁律：
---   - 用 vim.keymap.set（不是 nvim_set_keymap 或 safe_keymap_set）
---   - 永远带 desc（which-key 需要它）
---   - 插件 API 用 function 形式调用（懒加载）
---
--- 验证：nvim --headless -u NONE -c "luafile lua/config/keymaps.lua" -c 'qa!'

-- ============================================================================
-- 1. 新增快捷键
-- ============================================================================

-- 快速保存
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "保存文件", silent = true })

-- 快速退出
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "退出", silent = true })

-- 清除搜索高亮
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "清除搜索高亮", silent = true })

-- ============================================================================
-- 2. 自定义函数绑定
-- ============================================================================

-- 复制文件路径到剪贴板
vim.keymap.set("n", "<leader>fp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  print("已复制: " .. path)
end, { desc = "复制文件路径" })

-- 快速编辑配置文件
vim.keymap.set("n", "<leader>vc", function()
  local config_path = vim.fn.stdpath("config") .. "/lua/config/keymaps.lua"
  vim.cmd("edit " .. config_path)
end, { desc = "编辑快捷键配置" })

-- ============================================================================
-- 3. which-key 分组注册
-- ============================================================================

-- 追加自定义分组（LazyVim 默认分组见 README）
vim.keymap.set("n", "<leader>m", "", { desc = "+Markdown" })
vim.keymap.set("n", "<leader>p", "", { desc = "+项目" })

-- ============================================================================
-- 4. 多模式快捷键
-- ============================================================================

-- Ctrl+s 保存（普通模式和插入模式）
vim.keymap.set({ "n", "i" }, "<C-s>", function()
  vim.cmd("write")
end, { desc = "保存文件", silent = true })

-- ============================================================================
-- 5. 可视模式快捷键
-- ============================================================================

-- 可视模式下缩进后保持选择
vim.keymap.set("v", "<", "<gv", { desc = "缩进后保持选择" })
vim.keymap.set("v", ">", ">gv", { desc = "缩进后保持选择" })

-- 可视模式下移动选中行
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "下移选中行", silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "上移选中行", silent = true })
