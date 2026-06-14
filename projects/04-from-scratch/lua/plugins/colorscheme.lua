--- lua/plugins/colorscheme.lua — 配色方案（项目 4）
---
--- 从零配置配色方案，不依赖 LazyVim 的预配置。
--- 对照 Ch06 的内容，这里是你自己写的完整 spec。
---
--- LazyVim 帮你做的事情（你需要自己写）：
---   1. 安装 tokyonight.nvim
---   2. 配置 style、transparent 等选项
---   3. 设为默认配色（vim.cmd.colorscheme）
---   4. 设 priority = 1000 确保优先加载
---
--- 本文件只写 10 行，LazyVim 的默认配置有 20+ 行。

return {
  -- ========================================================================
  -- tokyonight.nvim — 配色方案
  -- ========================================================================
  -- Tokyonight 是 LazyVim 默认的配色方案。
  -- 从零配置时，你需要手动设置：
  --   1. 选项（style、transparent 等）
  --   2. 应用配色（vim.cmd.colorscheme）
  --
  -- priority = 1000 确保配色插件在其他插件之前加载。
  -- 如果配色加载晚了，其他插件会用默认配色，导致颜色不一致。
  {
    "folke/tokyonight.nvim",
    lazy = false,      -- 不懒加载（启动时就加载）
    priority = 1000,   -- 最高优先级
    opts = {
      style = "moon",      -- 配色风格：storm/night/day/moon
      transparent = false, -- 不透明背景
      terminal_colors = true, -- 终端也用主题色
    },
    -- config 函数：setup 后应用配色
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },
}
