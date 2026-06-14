--- init.lua — 从零手搓迷你 Neovim 配置（项目 4）
---
--- 这个文件是一个完整的、独立的 Neovim 配置入口。
--- 它不依赖 LazyVim，不 import LazyVim 的模块，
--- 从 lazy.nvim bootstrap 到每个插件的 spec 全部手写。
---
--- 对照 Kickstart.nvim 的结构，但拆分成多个文件：
---   init.lua（本文件）→ 基础配置 + bootstrap
---   lua/plugins/*.lua → 插件 spec
---
--- ⚠️ 在教程环境中，pcall guard 会打印 demo 消息后正常退出。
---    在真实环境中，去掉 pcall guard 即可正常运行。
---
--- 加载方式：nvim -u init.lua（或复制到 ~/.config/nvim/init.lua）

-- ============================================================================
-- 第 1 步：基础选项（vim.opt.*）
-- ============================================================================
-- LazyVim 的 lua/config/options.lua 做的事情完全一样。
-- 这些是 Neovim 的内置选项，不需要任何插件。

vim.g.mapleader = " "       -- Leader 键设为空格（LazyVim 默认也是空格）
vim.g.maplocalleader = "\\" -- Local Leader 键设为反斜杠

local opt = vim.opt

-- 行号
opt.number = true           -- 显示行号
opt.relativenumber = true   -- 相对行号（方便跳转）

-- 缩进
opt.tabstop = 2             -- Tab 显示为 2 空格
opt.shiftwidth = 2          -- 自动缩进 2 空格
opt.expandtab = true        -- Tab 转空格
opt.smartindent = true      -- 智能缩进

-- 搜索
opt.ignorecase = true       -- 搜索忽略大小写
opt.smartcase = true        -- 有大写字母时区分大小写
opt.hlsearch = true         -- 高亮搜索结果
opt.incsearch = true        -- 增量搜索

-- 分屏
opt.splitbelow = true       -- 水平分屏在下方
opt.splitright = true       -- 垂直分屏在右侧

-- 外观
opt.termguicolors = true    -- 真彩色
opt.signcolumn = "yes"      -- 始终显示 sign column（避免编辑区抖动）
opt.scrolloff = 8           -- 光标距屏幕顶部/底部 8 行时滚动
opt.wrap = false            -- 不自动换行

-- 性能
opt.updatetime = 250        -- 写入 swap 文件的间隔（ms）
opt.timeoutlen = 300        -- 按键超时（ms）

-- ============================================================================
-- 第 2 步：基础快捷键（vim.keymap.set）
-- ============================================================================
-- LazyVim 的 lua/config/keymaps.lua 做的事情完全一样。
-- 这些快捷键不依赖任何插件。

local map = vim.keymap.set

-- 窗口导航（最常用的快捷键）
map("n", "<C-h>", "<C-w>h", { desc = "跳转到左边窗口" })
map("n", "<C-j>", "<C-w>j", { desc = "跳转到下方窗口" })
map("n", "<C-k>", "<C-w>k", { desc = "跳转到上方窗口" })
map("n", "<C-l>", "<C-w>l", { desc = "跳转到右边窗口" })

-- 调整窗口大小
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "增加窗口高度" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "减少窗口高度" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "减少窗口宽度" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "增加窗口宽度" })

-- Buffer 切换
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "上一个 buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "下一个 buffer" })

-- 退出插入模式
map("i", "jk", "<ESC>", { desc = "退出插入模式" })
map("i", "kj", "<ESC>", { desc = "退出插入模式" })

-- 清除搜索高亮
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "清除搜索高亮" })

-- 保存和退出
map("n", "<leader>w", "<cmd>w<CR>", { desc = "保存" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "退出" })

-- ============================================================================
-- 第 3 步：lazy.nvim Bootstrap（安装插件管理器）
-- ============================================================================
-- 这是从零配置最关键的一步。
-- LazyVim 的 lua/config/lazy.lua 做的事情完全一样。
--
-- 流程：
--   1. 确定 lazy.nvim 的安装路径
--   2. 如果没装过，从 GitHub 克隆
--   3. 把 lazy.nvim 加到 runtimepath
--   4. 用 lazy.setup() 加载插件

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- pcall guard：教程环境中 lazy.nvim 可能没装
if not vim.loop.fs_stat(lazypath) then
  -- 尝试克隆 lazy.nvim
  local ok, result = pcall(vim.fn.system, {
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if not ok or vim.v.shell_error ~= 0 then
    -- 克隆失败（教程环境或网络问题），打印 demo 消息
    print("[demo] lazy.nvim 未安装。在真实环境中会自动克隆到: " .. lazypath)
    print("[demo] 运行以下命令手动安装:")
    print("  git clone --filter=blob:none https://github.com/folke/lazy.nvim.git \\")
    print("    --branch=stable " .. lazypath)
    return
  end
end

-- 把 lazy.nvim 加到 runtimepath（冒号语法，不是点语法）
vim.opt.rtp:prepend(lazypath)

-- pcall guard：如果 lazy.nvim 加载失败，打印 demo 消息
local lazy_ok, lazy = pcall(require, "lazy")
if not lazy_ok then
  print("[demo] require('lazy') 失败。在真实环境中 lazy.nvim 会正常加载。")
  print("[demo] 本文件的其余部分展示了 lazy.setup() 的完整写法。")
  return
end

-- ============================================================================
-- 第 4 步：lazy.setup() — 加载所有插件
-- ============================================================================
-- 这里只加载 lua/plugins/ 目录下的 spec 文件。
-- 不 import = "lazyvim.plugins"（这是从零配置的核心区别）。

lazy.setup({
  spec = {
    -- 自动加载 lua/plugins/*.lua
    -- lazy.nvim 会扫描这个目录，每个文件返回一个 spec table
    { import = "plugins" },
  },

  -- 安装配置
  install = {
    colorscheme = { "tokyonight" },  -- 安装时使用的配色
  },

  -- 检查更新配置
  checker = {
    enabled = true,       -- 自动检查插件更新
    notify = false,       -- 不弹通知（避免打扰）
  },

  -- 性能配置
  performance = {
    rtp = {
      -- 禁用 Neovim 内置的 Vim 时代插件（节省 5-15ms）
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
