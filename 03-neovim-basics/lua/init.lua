--- lua/init.lua — 第03章：完整的初学者 Neovim 配置
---
--- 这是 Part 0 的收官配置：整合第01-02章的选项 + 窗口/缓冲区相关设置 + 第一个 keymap。
--- 不依赖任何插件，纯 Neovim 原生 API。
---
--- 用法:
---   nvim -u lazyvim/03-neovim-basics/lua/init.lua
---   nvim --headless -u lazyvim/03-neovim-basics/lua/init.lua -c 'qa!'
---
--- 部署到真实环境:
---   cp lazyvim/03-neovim-basics/lua/init.lua ~/.config/nvim/init.lua
---   然后直接 nvim（不带 -u），Neovim 会自动加载。
---
--- 关于配置拆分:
---   本文件为了用 `-u` 测试方便，所有内容内联。
---   真实部署时，推荐把选项/键位/自动命令拆到 lua/config/*.lua，
---   然后 init.lua 只做 require("config.options") 等。
---   参考 lua/config/ 目录下的 options.lua / keymaps.lua / autocmds.lua。
---   （-u 加载时 runtimepath 不含本章 lua/ 目录，所以这里不能 require 本地模块）

-- ============================================================
-- 0. Leader 键（必须在所有 keymap 之前设置）
-- ============================================================

-- 用空格作为 Leader 键（第07章深入讲，这里先用起来）
-- g.mapleader 必须在定义任何 <leader> 键映射之前设置
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- ============================================================
-- 1. 界面选项（继承第01-02章）
-- ============================================================

vim.opt.number = true            -- 绝对行号
vim.opt.relativenumber = true    -- 相对行号（第03章新增：便于 10j 这种跳转）
vim.opt.cursorline = true        -- 高亮当前行
vim.opt.signcolumn = "yes"       -- 标志列常驻（避免 LSP 诊断时屏幕跳动）
vim.opt.termguicolors = true     -- 真彩色

-- ============================================================
-- 2. 缩进与制表符
-- ============================================================

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true        -- 继续上一行的缩进

-- ============================================================
-- 3. 搜索选项（继承第02章）
-- ============================================================

vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrapscan = true          -- 搜索到尾自动回到头部
vim.opt.inccommand = "split"     -- 替换命令实时预览

-- ============================================================
-- 4. 窗口与分屏（本章重点）
-- ============================================================

vim.opt.splitbelow = true        -- :split 新窗口在下方
vim.opt.splitright = true        -- :vsplit 新窗口在右侧
vim.opt.equalalways = true       -- 新建/关闭窗口时自动等分

-- ============================================================
-- 5. 缓冲区与文件
-- ============================================================

vim.opt.hidden = true            -- 允许隐藏缓冲区（:bn 不强制保存）
vim.opt.swapfile = false         -- 关闭 swap 文件
vim.opt.backup = false           -- 关闭备份
vim.opt.undofile = true          -- 持久化撤销历史（.undo 文件）
vim.opt.updatetime = 250         -- swap 写入间隔 + LSP 诊断触发间隔

-- ============================================================
-- 6. 显示与渲染
-- ============================================================

vim.opt.showmode = false         -- 不显示 -- INSERT --（插件会显示，这里先关）
vim.opt.cmdheight = 1            -- 命令行高度
vim.opt.wrap = true              -- 长行换行显示
vim.opt.scrolloff = 5            -- 光标距屏幕边缘 5 行时开始滚动
vim.opt.sidescrolloff = 8        -- 水平滚动边缘

-- 完成提示相关
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- 不可见字符显示（:set list 开启）
vim.opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
  extends = "›",
  precedes = "‹",
}

-- ============================================================
-- 7. 第一个 keymap（用 vim.keymap.set，不用废弃的 nvim_set_keymap）
-- ============================================================

-- 保存 / 退出（比 :w :q 快）
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "保存文件" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "退出" })
vim.keymap.set("n", "<leader>x", "<cmd>x<CR>", { desc = "保存并退出" })

-- 窗口导航（比 Ctrl-w hjkl 更顺手，不用按两步）
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "移到左窗口" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "移到下窗口" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "移到上窗口" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "移到右窗口" })

-- 缓冲区切换（比 :bn :bp 快）
vim.keymap.set("n", "<S-l>", "<cmd>bn<CR>", { desc = "下一个缓冲区" })
vim.keymap.set("n", "<S-h>", "<cmd>bp<CR>", { desc = "上一个缓冲区" })
vim.keymap.set("n", "<leader>bd", "<cmd>bd<CR>", { desc = "关闭缓冲区" })

-- 清除搜索高亮（:noh 的快捷版）
vim.keymap.set("n", "<leader>nh", "<cmd>noh<CR>", { desc = "清除搜索高亮" })

-- j/k 在视觉行间移动（长行换行时按屏幕行跳，不按逻辑行）
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "下移（视觉行）" })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "上移（视觉行）" })

-- ============================================================
-- 8. 自动命令示例（autocmd）
-- ============================================================

-- 创建 augroup，避免重复加载时 autocmd 重复注册
local group = vim.api.nvim_create_augroup("MyConfig", { clear = true })

-- 进入终端缓冲区时自动切到插入模式
vim.api.nvim_create_autocmd("TermOpen", {
  group = group,
  pattern = "*",
  command = "startinsert",
  desc = "终端启动即进入插入模式",
})

-- 保存时自动去除行尾空格（YAML/Python 等格式友好）
vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = "*",
  callback = function()
    -- 保存光标位置和搜索状态
    local save = vim.fn.winsaveview()
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
  desc = "保存前去除行尾空格",
})

-- ============================================================
-- 9. 完成提示
-- ============================================================

print("[03-neovim-basics] init.lua loaded OK (完整初学者配置)")
