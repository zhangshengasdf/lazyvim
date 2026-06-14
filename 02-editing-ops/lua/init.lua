--- lua/init.lua — 第02章：搜索相关选项配置
---
--- 在第01章基础选项之上，本章重点配置「搜索与替换」相关选项。
--- 用法:
---   nvim -u lazyvim/02-editing-ops/lua/init.lua
---   nvim --headless -u lazyvim/02-editing-ops/lua/init.lua -c 'qa!'
---
--- 本章新概念:
---   - incsearch / hlsearch: 搜索实时跳转与高亮
---   - ignorecase + smartcase: 大小写智能匹配
---   - inccommand: 替换命令的实时预览（Neovim 0.x 特性）

-- ============================================================
-- 1. 继承第01章的基础选项（这里重复声明，让本章配置可独立加载）
-- ============================================================

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.hidden = true

-- ============================================================
-- 2. 搜索核心选项（本章重点）
-- ============================================================

-- 输入搜索词时实时跳转到第一个匹配（输入 /fo 就跳到 foo，不用等回车）
-- 强烈推荐: 没有这个选项，每次搜索都要瞎等
vim.opt.incsearch = true

-- 高亮所有匹配结果（黄色背景）
-- 好处: 一眼看清匹配分布
-- 坏处: 搜完后黄色还在，分散注意力，需要 :noh 清除
vim.opt.hlsearch = true

-- 忽略大小写: /foo 能匹配 Foo FOO foO
-- 配合 smartcase 使用更智能
vim.opt.ignorecase = true

-- 智能大小写: 搜索词全小写时忽略大小写，有大写时严格匹配
-- 例: /foo 匹配 Foo FOO; /Foo 只匹配 Foo
-- 这是 ignorecase + smartcase 的黄金组合，几乎所有 Vim 老手都这么配
vim.opt.smartcase = true

-- ============================================================
-- 3. 替换预览（Neovim 特性，Vim 没有）
-- ============================================================

-- 输入 :s/old/new/ 时实时预览替换效果
-- "split" 在命令行上方开一个预览窗口; "nosplit" 只在原缓冲区高亮
-- Vim 默认是空字符串（无预览），Neovim 0.x 推荐 "split" 或 "nosplit"
vim.opt.inccommand = "split"

-- ============================================================
-- 4. 便利选项
-- ============================================================

-- 自动切换工作目录到当前文件所在目录
-- 好处: :e 和 :r 用相对路径更方便
-- 注意: 有些工作流不喜欢这个行为，按需开关
vim.opt.autochdir = false

-- 搜索时到达文件尾自动跳回文件头继续（环形搜索）
vim.opt.wrapscan = true

-- 命令行历史和搜索历史更长（默认 20，加大到 1000）
vim.opt.history = 1000

-- 完成提示（Ctrl-d 显示所有补全候选）
-- wildmenu: 命令行 Tab 补全时在状态栏显示候选
vim.opt.wildmenu = true

-- wildmode: 补全行为
-- "longest:full,full" = 先补到最长公共前缀，再显示完整菜单
vim.opt.wildmode = "longest:full,full"

-- ============================================================
-- 5. 完成提示
-- ============================================================

print("[02-editing-ops] init.lua loaded OK (搜索选项已配置)")
