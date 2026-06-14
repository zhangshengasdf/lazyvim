--- lua/plugins/ui.lua — Markdown 界面与预览（项目 3）
---
--- 本文件配置两个界面相关插件：
---   1. zen-mode.nvim — 专注模式（隐藏所有 UI 干扰）
---   2. markdown-preview.nvim — 浏览器实时 Markdown 预览
---
--- 两个插件都用 keys 懒加载——按快捷键时才加载，
--- 不影响不写作时的启动速度。
---
--- 文件返回 spec table，直接 luafile 加载不会报错。

return {
  -- ========================================================================
  -- 1. zen-mode.nvim — 专注模式
  -- ========================================================================
  -- zen-mode 隐藏行号、状态栏、sign column、tabline，
  -- 可选居中显示当前段落，让你专注于文字本身。
  --
  -- 懒加载策略：keys — 按 <leader>z 时才加载。
  -- 写作是"有时做"的任务，不需要每次启动都加载。
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
      { "<leader>z", "<cmd>ZenMode<CR>", desc = "专注模式" },
    },
    opts = {
      window = {
        backdrop = 1,       -- 背景变暗程度（0 = 全黑，1 = 不变暗）
        width = 120,        -- 窗口宽度（字符数）
        height = 1,         -- 高度 1 表示自适应
      },
      plugins = {
        -- 关闭这些 UI 元素
        options = {
          enabled = true,
          ruler = false,           -- 隐藏标尺
          showcmd = false,         -- 隐藏命令行
          laststatus = 0,          -- 隐藏状态栏
        },
        twilight = { enabled = false },  -- 不需要 twilight（只高亮当前段落）
        gitsigns = { enabled = false },  -- 隐藏 git 标记
        tmux = { enabled = false },      -- 不改变 tmux 状态栏
        -- zen-mode 的 kitty/wezterm 集成可以调整字体大小
        -- 如果你用 kitty 终端，可以启用：
        -- kitty = { enabled = true, font = "+4" },
      },
      -- 退出 zen-mode 时的回调（可选）
      on_open = function()
        -- 进入时启用拼写检查（写作时很有用）
        vim.opt_local.spell = true
        vim.opt_local.spelllang = { "en", "cjk" }
      end,
      on_close = function()
        -- 退出时恢复
        vim.opt_local.spell = false
      end,
    },
  },

  -- ========================================================================
  -- 2. markdown-preview.nvim — 浏览器实时预览
  -- ========================================================================
  -- 在浏览器中打开 Markdown 预览，编辑器和浏览器同步滚动。
  -- 支持图片、数学公式、Mermaid 图表等。
  --
  -- 懒加载策略：cmd + keys 双触发（Ch06 模式）。
  --   cmd = { "MarkdownPreview" } — 运行 :MarkdownPreview 时加载
  --   keys — 按快捷键时加载
  -- 两种方式都触发，灵活度最高。
  --
  -- ⚠️ 必须有 build 步骤：插件的前端需要 Node.js 构建。
  -- 不写 build，插件装了但预览页面打不开。
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    keys = {
      { "<leader>um", "<cmd>MarkdownPreviewToggle<CR>", desc = "Markdown 预览" },
    },
    -- build 在安装/更新后自动执行
    build = "cd app && npm install",
    -- init 在插件加载前执行（设置全局变量）
    -- 即使插件懒加载了，这些变量也会在启动时设好
    init = function()
      -- 设置预览选项
      vim.g.mkdp_auto_start = 0           -- 不自动打开预览
      vim.g.mkdp_auto_close = 1           -- 切换 buffer 时自动关闭预览
      vim.g.mkdp_refresh_slow = 0         -- 实时刷新（不延迟）
      vim.g.mkdp_browser = ""             -- 使用系统默认浏览器
      vim.g.mkdp_theme = "light"          -- 预览主题（light/dark）
      vim.g.mkdp_combine_preview = 1      -- 合并预览窗口（不重复打开）
      vim.g.mkdp_combine_preview_auto_refresh = 1  -- 合并后自动刷新
    end,
  },
}
