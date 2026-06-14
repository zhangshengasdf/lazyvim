--- lua/config/options.lua — vim 选项配置（第05章示例）
---
--- 这个文件演示常见的 vim 选项配置。
--- 真实使用时放在 ~/.config/nvim/lua/config/options.lua，LazyVim 自动 source。

-- ============================================================================
-- 显示相关
-- ============================================================================
vim.opt.number = true           -- 显示绝对行号
vim.opt.relativenumber = true   -- 显示相对行号（配合 5j 这种跳转）
vim.opt.cursorline = true       -- 高亮当前行
vim.opt.signcolumn = "yes"      -- 始终显示 sign column（避免抖动）

-- ============================================================================
-- 缩进相关
-- ============================================================================
vim.opt.tabstop = 2             -- Tab 显示为 2 空格宽
vim.opt.shiftwidth = 2          -- 自动缩进每级 2 空格
vim.opt.shiftround = true       -- 缩进对齐到 shiftwidth 的倍数
vim.opt.expandtab = true        -- Tab 键转空格
vim.opt.smarttab = true         -- 行首 Tab 按 shiftwidth 处理

-- ============================================================================
-- 搜索相关
-- ============================================================================
vim.opt.ignorecase = true       -- 搜索忽略大小写
vim.opt.smartcase = true        -- 但有大写时区分大小写（foo 不匹配 FOO，Foo 匹配 Foo）
vim.opt.hlsearch = false        -- 不高亮所有搜索结果（按 n 跳转即可）

-- ============================================================================
-- 颜色和 UI
-- ============================================================================
vim.opt.termguicolors = true    -- 启用 24-bit 真彩色（几乎所有现代终端支持）
vim.opt.showmode = false        -- 不显示 -- INSERT --（状态栏插件会处理）

-- ============================================================================
-- 全局变量（用 vim.g，不是 vim.opt）
-- ============================================================================
vim.g.mapleader = " "           -- Leader 键设为空格（必须在定义 keymap 之前设）
vim.g.maplocalleader = "\\"     -- Local leader 设为反斜杠

-- ============================================================================
-- 性能相关
-- ============================================================================
vim.opt.updatetime = 250        -- CursorHold 触发间隔（默认 4000ms 太慢）
vim.opt.timeoutlen = 300        -- which-key 弹出延迟（第 08 章详解）

-- 验证：用 shared/verify.lua 检查
--   local verify = dofile("shared/verify.lua")
--   verify.check_opt("number", true)      -- 应该通过
--   verify.check_opt("tabstop", 2)        -- 应该通过
--   verify.check_opt("mapleader", " ")    -- 注意 vim.g 用 vim.g 不是 vim.o
