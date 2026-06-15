--- lua/config/options.lua — 配置拆分参考：所有 vim.opt 选项设置
---
--- 这是「部署参考」文件。本章节用 `-u lua/init.lua` 测试时不会加载它
--- （因为 -u 不把章节 lua/ 目录加入 runtimepath）。
---
--- 真实部署时（拷到 ~/.config/nvim/）：
---   1. 把本文件放到 ~/.config/nvim/lua/config/options.lua
---   2. ~/.config/nvim/init.lua 里写 require("config.options")
---   3. 这样 Neovim 启动时会自动加载

-- Leader 键必须在 keymap 之前设置（这里也声明一次，确保顺序）
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 界面
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true

-- 缩进
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- 搜索
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrapscan = true
vim.opt.inccommand = "split"

-- 窗口与分屏
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.equalalways = true

-- 缓冲区与文件
vim.opt.hidden = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.updatetime = 250

-- 显示
vim.opt.showmode = false
vim.opt.cmdheight = 1
vim.opt.wrap = true
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 8
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.completeopt = { "menu", "menuone", "noselect" }

vim.opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
  extends = "›",
  precedes = "‹",
}

return nil -- 选项模块不返回值
